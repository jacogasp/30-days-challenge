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
	if area is Bullet:
		area.disable()
	if area is Barrel:
		area._explode(true)
	if area is Enemy:
		area.hit(50)
