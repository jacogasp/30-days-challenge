extends Node2D

@export var speed: float = 100
@export var health_max: int = 100
@export var starting_sailors: int  = 3
@onready var health = health_max
@export var sailor_scene: PackedScene
@onready var sailors: Node2D = $Sailors

var boat_length:int  = 100

signal enemy_spawned
signal enemy_defeated


func _ready() -> void:
	$Label.hide()
	for i in starting_sailors:
		var sailor := sailor_scene.instantiate()
		var sailor_offset = Vector2(randf_range(-boat_length * 0.5, boat_length * 0.5), 0)
		sailors.add_child(sailor)
		sailor.position = sailor_offset
		sailor.spawn_position = sailor.position
		sailor.modulate = Color.from_hsv(randf(),
										 randf_range(0.6,0.8),
										 randf_range(0.9, 1))


func _physics_process(delta: float) -> void:
	position.x += speed * delta


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	enemy_spawned.emit()


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()


func hit(damage: int) -> void:
	if ($Label.hidden):
		$Label.show()
	health -= damage
	$Label.text = str(health)
	if (health <= 0):
		enemy_defeated.emit()
		queue_free()
