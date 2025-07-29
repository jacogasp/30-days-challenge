class_name Barrel
extends Area2D

@export var damage: int = 5

@onready var sprite = $ClippingContainer/Sprite2D
@onready var wave_particles = $WaveParticles
@onready var explosion_particles = $ExplosionParticles
@onready var hit_audio_player = $HitAudioStreamPlayer2D
@onready var explode_audio_player = $ExplodeAudioStreamPlayer2D

var exploding: bool = false

func _ready() -> void:
	var mat: ShaderMaterial = sprite.material
	mat.set_shader_parameter("start_angle", randf() * PI * 0.5)


func _process(delta: float) -> void:
	position += Globals.world_speed * Vector2.LEFT * delta * 0.5
	if global_position.x < -250:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Interact only with player and its bullets
	if not exploding:
		if area.has_method("hit"):
			area.call("hit", damage)
		explode(false)


func hit(_damage: float) -> void:
	if not exploding:
		explode(true)


func explode(by_bullet: bool) -> void:
	exploding = true
	explosion_particles.emitting = true
	wave_particles.visible = false
	wave_particles.emitting = false
	sprite.visible = false
	set_process(false)
	set_physics_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	if by_bullet:
		hit_audio_player.play()
	else:
		explode_audio_player.play()
	await get_tree().create_timer(3).timeout
	queue_free()
