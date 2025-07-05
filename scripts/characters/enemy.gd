extends Sprite2D

@export var speed: float = 100

func _physics_process(delta: float) -> void:
	position.x += speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
