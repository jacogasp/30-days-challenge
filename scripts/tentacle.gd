extends Node2D
@onready var sprite_2d: Sprite2D = $ClippingControl/Sprite2D

func _ready() -> void:
	var tween:Tween = create_tween()
	sprite_2d.position.y = 600
	tween.tween_property(sprite_2d, "position:y", randf_range(300, 380), 3.)
	
