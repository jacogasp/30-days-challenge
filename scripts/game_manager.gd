extends Node2D

var spawned_enemies: int = 0
var defeated_enemies: int = 0
var _game_is_running: bool = false
var _high_score: int = 0
var _score: float = 0
var _current_score: int = 0
var _difficulty_per_score: int = 100
var _difficulty: int = 1

signal enemy_just_spawned
signal enemy_just_defeated
signal sailor_count_updated
signal score_updated
signal difficulty_changed
signal game_over


func _process(delta: float) -> void:
	if not _game_is_running:
		return

	_score += Globals.tick_score_multiplier * delta
	var score = ceil(_score)
	if score > current_score():
		_current_score = score
		score_updated.emit(current_score())
		_update_difficulty()


func start() -> void:
	_game_is_running = true


func stop() -> void:
	_game_is_running = false


func reset() -> void:
	spawned_enemies = 0
	defeated_enemies = 0
	_current_score = 0
	_score = 0
	_difficulty = 1


func current_score() -> int:
	return _current_score


func high_score() -> int:
	return _high_score


func _update_difficulty() -> void:
	var difficulty: int = ceil(_score / _difficulty_per_score)
	if difficulty > _difficulty:
		_difficulty = difficulty
		difficulty_changed.emit(current_difficulty())


func current_difficulty() -> int:
	return _difficulty


func enemy_spawned() -> void:
	spawned_enemies += 1
	enemy_just_spawned.emit(spawned_enemies)


func enemy_hit() -> void:
	_score += Globals.hit_score * Globals.sink_score_multiplier
	score_updated.emit(current_score())


func enemy_defeated() -> void:
	defeated_enemies += 1
	_score += Globals.sink_score * Globals.sink_score_multiplier
	score_updated.emit(current_score())
	enemy_just_defeated.emit(defeated_enemies)


func update_sailors_count(count: int) -> void:
	_score += Globals.sailor_score * Globals.sailor_score_multiplier
	score_updated.emit(current_score())
	sailor_count_updated.emit(count)


func overboard_sailor(sailor: Sailor, sailor_position: Vector2) -> void:
	add_child(sailor)
	sailor.set_overboard()
	sailor.global_position = sailor_position


func _game_over() -> void:
	stop()
	reset()
	if current_score() > _high_score:
		_high_score = current_score()
	game_over.emit()
