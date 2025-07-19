extends Label

@export var value: int = 100
@export var transform_scale: float = 1.3




func _ready() -> void:
	text = str(value)
	var tween = create_tween()
	tween.parallel().tween_property(self, "scale", Vector2(transform_scale, transform_scale), 0.2)
	tween.parallel().tween_property(self, "position", position + Vector2(0, -100), 0.2)
	await tween.finished
	print("transparent")
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	await tween.finished
	print("finished")
	queue_free()
