extends Sprite2D

@export var speed: float = 100
signal enemy_spawned
signal enemy_destroyed

func _physics_process(delta: float) -> void:
	position.x += speed * delta

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	enemy_spawned.emit()

func _on_visible_on_screen_notifier_2d_screen_exited():
	enemy_destroyed.emit()
	queue_free()
