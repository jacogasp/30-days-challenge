class_name EnemyGun
extends Gun

@export var bullet_color: Color = Color.from_hsv(0,0,1,1)

func _ready() -> void:
	bullet_pool = EnemyBulletPool
	bullet_pool.init_pool(bullet_scene)

func fire_ring(bullet_count: int = 16) -> void:
	var angle_step: float = 2 * PI / bullet_count
	for i in range(bullet_count):
		var angle = angle_step * i
		var direction = Vector2(cos(angle), sin(angle))
		var origin = global_position + direction
		var bullet: Bullet = bullet_pool.get_bullet()
		if bullet:
			_setup_bullet(bullet, origin, direction, angle)

func fire_single(arg) -> void:
	var angle: float
	if arg is Vector2:
		angle = arg.angle()
	elif arg is float:
		angle = arg
	else:
		push_error("Type not supported")
		return
	_fire_single_from_angle(angle)

func _fire_single_from_angle(angle: float) -> void:
	var direction = Vector2(cos(angle), sin(angle))
	var origin = global_position + direction
	var bullet: Bullet = bullet_pool.get_bullet()
	if bullet:
		_setup_bullet(bullet, origin, direction, angle)

func fire_spread(bullet_count: int, arg, spread_angle: float) -> void:
	if bullet_count <= 0:
		return
	if bullet_count == 1:
		fire_single(arg)
		return
	var base_angle: float
	if arg is Vector2:
		base_angle = arg.angle()
	elif arg is float:
		base_angle = arg
	else:
		push_error("Type not supported")
		return
	_fire_spread_from_angle(bullet_count, base_angle, spread_angle)

func _fire_spread_from_angle(bullet_count: int, angle: float, spread_angle: float) -> void:
	var spread_radians = deg_to_rad(spread_angle)
	var angle_step = spread_radians / (bullet_count - 1)
	var start_angle = angle - spread_radians / 2
	for i in range(bullet_count):
		var bullet_angle = start_angle + (angle_step * i)
		var bullet_direction = Vector2(cos(bullet_angle), sin(bullet_angle))
		var origin = global_position + bullet_direction
		var bullet: Bullet = bullet_pool.get_bullet()
		if bullet:
			_setup_bullet(bullet, origin, bullet_direction, bullet_angle)

func _setup_bullet(bullet: Bullet, origin: Vector2, direction: Vector2, bullet_rotation: float, bullet_scale: Vector2 = Vector2(0.5, 0.5), speed: float = 400) -> void:
	bullet.scale = bullet_scale
	bullet.speed = speed
	bullet.rotation = bullet_rotation
	bullet.damage = 1
	bullet.sprite_2d.modulate = bullet_color
	bullet.fire(origin, direction)
	audio_player.play()
