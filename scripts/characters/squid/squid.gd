extends StaticBody2D
const TENTACLE = preload("res://scenes/characters/squid/tentacle.tscn")
@onready var tentacle_nodes: Node2D = $Tentacles
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shield_effect: Sprite2D = $ClippingControl/Body/ShieldEffect
@onready var debug_label: Label = $DEBUGLabel


@export var health:int = 1000
@export_range(1,8,1,"hide_slider") var difficulty: int = 2
@export var tentacle_position:Array[Vector2]

var tentacles:Array[Tentacle] = []

enum Squid_State{spawning, phase1, phase2}
var current_state:Squid_State = Squid_State.spawning
var emerged_count: int = 0
var submerged_count: int = 0

var submerged:bool = false
var flash_timer: Timer
@export var flash_duration: float = 0.1
var last_body_position: Vector2 = Vector2.ZERO  # Track position changes

func _set_up_timer() -> void:
	flash_timer = Timer.new()
	flash_timer.wait_time = flash_duration
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_timeout)
	add_child(flash_timer)

func _ready() -> void:
	_set_up_timer()
	for i in range(difficulty):
		var tentacle = TENTACLE.instantiate()
		tentacle.position = tentacle_position[i]
		tentacle.emerged.connect(_on_tentacle_emerged)
		tentacle.submerged.connect(_on_tentacle_submerged)
		tentacles.append(tentacle)
		tentacle_nodes.add_child(tentacle)
		tentacle.animation_player.play("RESET")
	await animate_appear()
	
func _process(delta: float) -> void:
	match current_state:
		Squid_State.spawning:
			pass
		Squid_State.phase1:
			for tentacle in tentacles:
				if randf() < 0.5:
					await tentacle.attack(tentacle.AttackType.barrel)
				else:
					await tentacle.attack(tentacle.AttackType.charge)
			animation_player.play("emerge")
			fire()
			animation_player.play("half_submerge")
			pass
		Squid_State.phase2:
			pass


func animate_appear() -> void:
	animation_player.play("emerge")
	await get_tree().create_timer(1).timeout
	for tentacle in tentacles:
		await get_tree().create_timer(randf()).timeout
		tentacle.min_position_y = randf_range(400,300)
		tentacle.animation_player.play("emerge")
	await animation_player.animation_finished
	animate_start_phase1()

func animate_start_phase1() -> void:
	animation_player.play("half_submerge")
	for tentacle in tentacles:
		tentacle.animation_player.play("submerge")
	await get_tree().create_timer(1).timeout
	submerged = true

func _on_tentacle_emerged() -> void:
	emerged_count += 1
	if emerged_count == tentacles.size():
		pass

func _on_tentacle_submerged() -> void:
	submerged_count += 1
	if submerged_count == tentacles.size() and current_state == Squid_State.spawning:
		animation_player.play("half_submerge")
		await animation_player.animation_finished
		current_state = Squid_State.phase1

func _on_area_hit(damage:int, pos:Vector2) -> void:
	if submerged:
		show_shield_effect(pos)
		return
	GameManager.enemy_hit()
	material.set_shader_parameter("flash_value", 1.0)
	flash_timer.start()
	health -= damage
	debug_label.text = str(health)
	if (health <= 0):
		die()

func show_shield_effect(pos:Vector2) -> void:
	shield_effect.visible = true
	shield_effect.global_position = pos
	flash_timer.start()

func die():
	pass

func fire():
	print("fire")

func _on_flash_timeout() -> void:
	material.set_shader_parameter("flash_value", 0.0)
	shield_effect.visible = false
	
