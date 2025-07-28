extends Area2D
@onready var explosion_particles: GPUParticles2D = $ExplosionParticles
@onready var barrel_sprite: Sprite2D = $BarrelSprite
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $BarrelSprite/AudioStreamPlayer2D

@export var health: int = 15
@export var barrel_type:GameManager.BarrelType

var is_exploding:bool = false
var flash_timer: Timer
@export var flash_duration: float = 0.1

signal barrel_exploded

func _ready() -> void:
	_set_up_timer()

func _set_up_timer() -> void:
	flash_timer = Timer.new()
	flash_timer.wait_time = flash_duration
	flash_timer.one_shot = true
	flash_timer.timeout.connect(_on_flash_timeout)
	add_child(flash_timer)


func hit(damage: int) -> void:
	if is_exploding:
		return
	material.set_shader_parameter("flash_value", 1.0)
	flash_timer.start()
	health -= damage
	if (health <= 0):
		explode(false)

func explode(_by_bullet:bool):
	is_exploding = true	
	explosion_particles.emitting = true
	visible = false
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	audio_stream_player_2d.play()
	if barrel_type == GameManager.BarrelType.TNT:
		barrel_exploded.emit()
	
	
func _on_flash_timeout() -> void:
	material.set_shader_parameter("flash_value", 0.0)
