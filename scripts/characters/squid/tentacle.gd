class_name Tentacle
extends StaticBody2D

enum AttackType{barrel,charge}

@onready var sprite_2d: Sprite2D = $ClippingControl/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
signal emerged
signal submerged
@onready var barrel_area: Area2D = $BarrelArea

@export var charge_duration:float = 4

@export var min_position_y: float = 300
@export var sprite_position_y: float :
	get:
		return sprite_2d.position.y
	set(value):
		if sprite_2d:
			sprite_2d.position.y = max(value, min_position_y)

var _barrel:Barrel = null

func _ready() -> void:
	_disable_barrel()

func set_submerged() -> void:
	sprite_2d.position.y = 530
	
func emerge(time:float) -> void:
	var tween:Tween = create_tween()
	set_submerged()
	await tween.tween_property(sprite_2d, "position:y", randf_range(300, 380), time).finished
	emerged.emit()

func submerge(time:float) -> void:
	var tween:Tween = create_tween()
	await tween.tween_property(sprite_2d, "position:y", 530, time).finished
	submerged.emit()

func emerge_with_barrel(barrel: Barrel) -> void:
	_barrel = barrel
	pass

func charge() -> void:
	var tween = create_tween()
	tween.tween_property(self, "position:x", -100, charge_duration)

func toss() -> void:
	pass

func attack(attack_type:AttackType):
	match attack_type:
		AttackType.barrel:
			pass
		AttackType.charge:
			pass

func _disable_barrel() -> void:
	barrel_area.visible = false
	barrel_area.monitorable = false
	barrel_area.monitoring = false
