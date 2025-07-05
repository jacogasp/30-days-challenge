extends Sprite2D

@export var speed: float = 100
@export var health_max: int = 100

@onready var health = health_max

signal enemy_spawned
signal enemy_destroyed

func _ready() -> void:
	$Label.hide()

func _physics_process(delta: float) -> void:
	position.x += speed * delta


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	enemy_spawned.emit()


func _on_visible_on_screen_notifier_2d_screen_exited():
	enemy_destroyed.emit()
	queue_free()


func hit(damage: int) -> void:
	if ($Label.hidden):
		$Label.show()
	health -= damage
	$Label.text = str(health)
	if (health <= 0):
		queue_free()
