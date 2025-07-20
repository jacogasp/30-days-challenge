class_name Barrel
extends Area2D

@export var damage: int = 5
@onready var sprite = $ClippingContainer/Sprite2D
@onready var wave_particles = $WaveParticles
@onready var explosion_particles = $ExplosionParticles
@onready var queue_free_timer = $QueueFreeTimer


func _ready() -> void:
	var mat: ShaderMaterial = sprite.material
	mat.set_shader_parameter("start_angle", randf() * PI * 0.5)


func _process(delta: float) -> void:
	position +=  Globals.world_speed * Vector2.LEFT * delta * 0.5
	if global_position.x < 0:
		queue_free_timer.start()


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("hit"):
		area.call("hit", damage)
		explosion_particles.emitting = true
		wave_particles.visible = false
		wave_particles.emitting = false
		sprite.visible = false
		queue_free_timer.start()


func _on_queue_free_timer_timeout() -> void:
	queue_free()
