class_name Gun
extends Node2D

@export var bullet_scene: PackedScene
@export var fire_rate: float = 4
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

enum FireMode {Single, Double, Triple}

var bullet_pool: BulletPool
var bullets_to_spawn := 0.0
var is_firing = false
var fire_mode = FireMode.Single

func _ready() -> void:
	bullet_pool = PlayerBulletPool
	bullet_pool.init_pool(bullet_scene)
	GameManager.power_level_updated.connect(_update_fire_level)


func _process(delta: float):
	if (is_firing):
		bullets_to_spawn += fire_rate * delta
		if bullets_to_spawn >= 1:
			for i in int(bullets_to_spawn):
				fire_bullet()
			bullets_to_spawn -= int(bullets_to_spawn)
		is_firing = false


func fire_bullet():
	match fire_mode:
		FireMode.Single:
			var bullet = bullet_pool.get_bullet()
			bullet.fire(global_position, Vector2.RIGHT)
			bullet.scale = Vector2(0.5, 0.5)
			bullet.enable()
		FireMode.Double:
			var bullet1 = bullet_pool.get_bullet()
			var offset = Vector2(0, 6)
			bullet1.fire(global_position - offset, Vector2.RIGHT)
			bullet1.scale = Vector2(0.5, 0.5)
			bullet1.enable()
			var bullet2 = bullet_pool.get_bullet()
			bullet2.fire(global_position + offset, Vector2.RIGHT)
			bullet2.scale = Vector2(0.5, 0.5)
			bullet2.enable()
		FireMode.Triple:
			var bullet1 = bullet_pool.get_bullet()
			var offset = Vector2(0, 12)
			bullet1.fire(global_position - offset, Vector2.RIGHT)
			bullet1.scale = Vector2(0.5, 0.5)
			bullet1.enable()
			var bullet2 = bullet_pool.get_bullet()
			bullet2.fire(global_position, Vector2.RIGHT)
			bullet2.scale = Vector2(0.5, 0.5)
			bullet2.enable()
			var bullet3 = bullet_pool.get_bullet()
			bullet3.fire(global_position + offset, Vector2.RIGHT)
			bullet3.scale = Vector2(0.5, 0.5)
			bullet3.enable()
	audio_player.play()


func fire():
	is_firing = true

func reset():
	bullet_pool.reset()

func _update_fire_level(level):
	if level <= 1:
		fire_rate = 4
		fire_mode = FireMode.Single
	if level > 1:
		fire_rate = 5
		fire_mode = FireMode.Single
	if level == 3:
		fire_mode = FireMode.Double
	if level == 4:
		fire_mode = FireMode.Triple
