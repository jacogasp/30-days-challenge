class_name Tentacle
extends StaticBody2D

enum AttackType{barrel,charge}
@onready var hurt_area_2d: Area2D = $HurtArea2D

@onready var sprite_2d: Sprite2D = $ClippingControl/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
signal emerged
signal submerged
signal attack_finished
@onready var barrel_area: Area2D = $BarrelArea

@export var damage:int = 1
@export var charge_duration:float = 1

@export var min_position_y: float = 300
@export var sprite_position_y: float :
	
	get:
		return sprite_2d.position.y
	set(value):
		if sprite_2d:
			sprite_2d.position.y = max(value, min_position_y)

var _barrel:Barrel = null

func _ready() -> void:
	animation_player.play("RESET")
	_disable_barrel()

func set_submerged() -> void:
	sprite_2d.position.y = 530
	
func emerge_with_barrel(barrel: Barrel) -> void:
	_barrel = barrel
	pass

func charge() -> void:
	print("Charge function started")
	var tween = create_tween()
	var current_x = global_position.x
	tween.tween_property(self, "global_position:x", current_x + 50, charge_duration * 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position:x", -100, charge_duration * 0.8).set_ease(Tween.EASE_IN)
	await tween.finished
	set_submerged()


func toss() -> void:
	pass

func attack(attack_type:AttackType):
	match attack_type:
		AttackType.barrel:
			# TODO: Implement barrel attack
			attack_finished.emit()
		AttackType.charge:
			animation_player.play("emerge")
			await animation_player.animation_finished
			hurt_area_2d.monitoring = true
			await charge()
			hurt_area_2d.monitoring = false
			attack_finished.emit()

func _disable_barrel() -> void:
	barrel_area.visible = false
	barrel_area.monitorable = false
	barrel_area.monitoring = false


func _on_hurt_area_entered(area: Area2D) -> void:
	print(area)
	if area.has_method("hit"):
		area.call("hit", damage)
