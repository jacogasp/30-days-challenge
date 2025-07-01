extends Sprite2D

@export var amplitude = 10.0
@export var frequency = 1.0

var t = 0.0

func _process(delta: float) -> void:
  position = Vector2.UP * amplitude * sin(2 * PI * frequency * t)
  t += delta
