class_name Tentacle
extends StaticBody2D
@onready var sprite_2d: Sprite2D = $ClippingControl/Sprite2D
signal emerged
signal submerged

func _ready() -> void:
	emerge()

func emerge() -> void:
	var tween:Tween = create_tween()
	sprite_2d.position.y = 530
	await tween.tween_property(sprite_2d, "position:y", randf_range(300, 380), 3.).finished
	emerged.emit()

func submerge() -> void:
	var tween:Tween = create_tween()
	await tween.tween_property(sprite_2d, "position:y", 530, 2.).finished
	submerged.emit()
