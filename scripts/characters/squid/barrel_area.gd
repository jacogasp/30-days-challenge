extends Area2D
@onready var explosion_particles: GPUParticles2D = $ExplosionParticles
@onready var barrel_sprite: Sprite2D = $BarrelSprite
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $BarrelSprite/AudioStreamPlayer2D

@export var health: int = 20

var is_exploding:bool = false
var flash_timer: Timer
@export var flash_duration: float = 0.1

func _set_up_timer() -> void:
	flash_timer = Timer.new()
	flash_timer.wait_time = flash_duration
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_timeout)
	add_child(flash_timer)


func hit(damage: int) -> void:
	if is_exploding:
		return
	GameManager.enemy_hit()
	material.set_shader_parameter("flash_value", 1.0)
	flash_timer.start()
	health -= damage
	if (health <= 0):
		explode()

func explode():
	is_exploding = true	
	explosion_particles.emitting = true
	barrel_sprite.visible = false
	set_process(false)
	set_physics_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	audio_stream_player_2d.play()
	
	
func _on_flash_timeout() -> void:
	material.set_shader_parameter("flash_value", 0.0)
