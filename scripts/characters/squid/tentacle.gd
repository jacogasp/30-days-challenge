class_name Tentacle
extends StaticBody2D

enum AttackType{barrel,charge}
@onready var hurt_area_2d: Area2D = $HurtArea2D

@onready var sprite_2d: Sprite2D = $ClippingControl/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
signal emerged
signal submerged
signal attack_finished
signal tentacle_hit

@onready var barrel_area: Area2D = $ClippingControl/Sprite2D/BarrelArea
@onready var barrel_sprite: Sprite2D = $ClippingControl/Sprite2D/BarrelArea/BarrelSprite

@export var damage:int = 1
@export var charge_duration:float = 1

@export var min_position_y: float = 300

var flash_timer: Timer
@export var flash_duration: float = 0.1

@export var sprite_position_y: float :
	get:
		return sprite_2d.position.y
	set(value):
		if sprite_2d:
			sprite_2d.position.y = max(value, min_position_y)

func _set_up_timer() -> void:
	flash_timer = Timer.new()
	flash_timer.wait_time = flash_duration
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_timeout)
	add_child(flash_timer)

func _ready() -> void:
	_set_up_timer()
	animation_player.play("RESET")
	_disable_barrel()

func set_submerged() -> void:
	sprite_2d.position.y = 530
	
func emerge_with_barrel(barrel_type: GameManager.BarrelType) -> void:
	barrel_area.barrel_type = barrel_type
	match barrel_type:
		GameManager.BarrelType.TNT:
			barrel_sprite.texture = load("res://assets/barrel_tnt.png")
		GameManager.BarrelType.PRIMARY:
			barrel_sprite.texture = load("res://assets/barrel_powerup.png")
		GameManager.BarrelType.SECONDARY:
			barrel_sprite.texture = load("res://assets/barrel_secondary.png")
	_enable_barrel()
	animation_player.play("emerge")
	await animation_player.animation_finished
	emerged.emit()


func emerge() -> void:
	animation_player.play("emerge")
	await animation_player.animation_finished
	emerged.emit()

func submerge() -> void:
	animation_player.play("submerge")
	await animation_player.animation_finished
	submerged.emit()

func charge() -> void:
	print("Charge function started")
	var tween = create_tween()
	var current_x = global_position.x
	tween.tween_property(self, "global_position:x", current_x + 50, charge_duration * 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:x", -100, charge_duration * 0.8).set_ease(Tween.EASE_IN)
	await tween.finished
	set_submerged()


func toss() -> void:
	if barrel_area.is_exploding:
		return
	animation_player.play("toss")
	await animation_player.animation_finished
	var tmp_barrel_sprite = barrel_sprite.duplicate()
	var start_position = barrel_sprite.global_position
	var toss_duration = 1.0
	tmp_barrel_sprite.global_position = start_position
	add_sibling(tmp_barrel_sprite)
	_disable_barrel()
	var offset_right = Vector2(100, 0)
	var offset_random = Vector2(randf_range(-50, 50), randf_range(-50, 50))
	var target_position = Globals.player.global_position + offset_right + offset_random
	# clamp target position to the screen limits
	target_position.clamp(Globals.min_sea_limit, Globals.max_sea_limit)
	var tween = create_tween()
	tween.set_parallel(true)
	# Horizontal movement (linear)
	tween.tween_property(tmp_barrel_sprite, "position:x", target_position.x, toss_duration).set_ease(Tween.EASE_OUT)
	# Vertical movement (parabolic arc)
	var arc_height = -150 
	var mid_y = start_position.y + arc_height
	tween.tween_method(_update_barrel_y_position.bind(start_position.y, mid_y, target_position.y, tmp_barrel_sprite), 0.0, 1.0, toss_duration).set_ease(Tween.EASE_IN_OUT)
	# Rotation
	tween.tween_property(tmp_barrel_sprite, "rotation_degrees", 180, toss_duration).set_ease(Tween.EASE_IN_OUT)
	# Scale
	tween.tween_property(tmp_barrel_sprite, "scale", Vector2(0.45, 0.45), toss_duration).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	GameManager.spawn_barrel_at_position(barrel_area.barrel_type, target_position)
	tmp_barrel_sprite.queue_free()


func attack(attack_type:AttackType):
	match attack_type:
		AttackType.barrel:
			var barrel_type = GameManager.get_random_barrel_type()
			await emerge_with_barrel(barrel_type)
			await get_tree().create_timer(0.4).timeout
			await toss()
			submerge()
			await animation_player.animation_finished
			attack_finished.emit()
		AttackType.charge:
			emerge()
			await animation_player.animation_finished
			hurt_area_2d.monitoring = true
			await charge()
			hurt_area_2d.monitoring = false
			attack_finished.emit()

func _disable_barrel() -> void:
	barrel_area.visible = false
	barrel_area.monitorable = false
	barrel_area.monitoring = false

func _enable_barrel() -> void:
	barrel_area.is_exploding = false
	barrel_area.visible = true
	barrel_area.monitorable = true
	barrel_area.monitoring = true

func _on_hurt_area_entered(area: Area2D) -> void:
	print(area)
	if area.has_method("hit"):
		area.call("hit", damage)

# Helper function to create parabolic trajectory
func _update_barrel_y_position(progress: float, start_y: float, mid_y: float, end_y: float, current_barrel_sprite: Sprite2D) -> void:
	var t = progress
	var y = (1 - t) * (1 - t) * start_y + 2 * (1 - t) * t * mid_y + t * t * end_y
	current_barrel_sprite.position.y = y


func _on_barrel_exploded() -> void:
	material.set_shader_parameter("flash_value", 1.0)
	flash_timer.start()
	tentacle_hit.emit(50)

func _on_flash_timeout() -> void:
	material.set_shader_parameter("flash_value", 0.0)
