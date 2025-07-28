extends Area2D

func _ready() -> void:
	GameManager.bomb_deployed.connect(_expand_area)

func _expand_area() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(100, 100), 0.5).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0,0), 0.2)

func _on_area_entered(area: Area2D) -> void:
	print(area.collision_layer)
	if area.collision_layer == 16 && area.has_method("disable"): #bullet
		area.disable()
	if area.collision_layer == 32 && area.has_method("explode"): #barrel
		area.explode(true)
	if area.collision_layer == 64 && area.has_method("hit"): #enemy
		area.hit(75)
