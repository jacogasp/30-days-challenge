extends Sprite2D

@export var max_speed: float = 320.
@export var fire_rate: float = 15
@export var bullet_scene: PackedScene
@export var bullet_pool_size: int = 5000

var bullet_pool: Array[Bullet] = []
var pool_index: int = 0
var bullets_to_spawn = 0
var speed := max_speed
var initial_scale: Vector2 = Vector2.ONE
var particle_emitter_orig_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
  particle_emitter_orig_pos = $GPUParticles2D.position
  for i in bullet_pool_size:
    bullet_pool.append(bullet_scene.instantiate())
  initial_scale = bullet_pool[0].scale

func _process(delta: float) -> void:
  var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
  position += direction * speed * delta

  if direction.x < 0:
    $GPUParticles2D.position.x = -particle_emitter_orig_pos.x
  elif direction.x > 0:
    $GPUParticles2D.position.x = particle_emitter_orig_pos.x
  if direction != Vector2.ZERO and !$GPUParticles2D.emitting:
    $GPUParticles2D.emitting = true
  elif direction == Vector2.ZERO and $GPUParticles2D.emitting:
    $GPUParticles2D.emitting = false
  
  if Input.is_action_pressed("fire"):
    speed = max_speed / 1.75
    bullets_to_spawn += fire_rate * delta
    if bullets_to_spawn < 1:
      pass
    for i in bullets_to_spawn:
      var bullet = bullet_pool[pool_index]
      pool_index = wrapi(pool_index + 1, 0, bullet_pool_size)
      add_child(bullet)
      var bullet_transform = global_transform
      bullet.fire(bullet_transform, 0.03)
      bullet.scale = initial_scale
    bullets_to_spawn -= round(bullets_to_spawn)
  else:
    speed = max_speed
