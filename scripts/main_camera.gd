extends Camera2D

const SHAKE_AMOUNT := 5000.0

var _noise := FastNoiseLite.new()
var _shake_time_remaining := 0.0
var _base_position := Vector2.ZERO
var _shake_duration := 1.0

func _ready() -> void:
	_base_position = global_position
	_noise = FastNoiseLite.new()


func _process(delta: float) -> void:
	if _shake_time_remaining > 0.0:
		global_position = _base_position + Vector2(_get_noise(0), _get_noise(1))*0.5
		_shake_time_remaining -= delta
		if _shake_time_remaining <= 0.0:
			global_position = _base_position


func shake(duration: float = 1.0) -> void:
	_shake_duration = duration
	_shake_time_remaining = duration
	_base_position = global_position


func _get_noise(seed: int) -> float:
	_noise.seed = seed
	return _noise.get_noise_1d(randf() * _shake_time_remaining) * SHAKE_AMOUNT
