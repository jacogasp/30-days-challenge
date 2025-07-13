extends Node2D

var spawned_enemies: int = 0
var defeated_enemies: int = 0
var _high_score: int = 0
var _score: float = 0

signal enemy_just_spawned
signal enemy_just_defeated
signal sailor_count_updated
signal score_updated
signal game_over


func _process(delta: float) -> void:
	_score += Globals.tick_score_multiplier * delta
	if _score > current_score():
		score_updated.emit(current_score())


func reset() -> void:
	spawned_enemies = 0
	defeated_enemies = 0
	_score = 0


func current_score() -> int:
	return int(_score)


func high_score() -> int:
	return _high_score


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
	if current_score() > _high_score:
		_high_score = current_score()
	game_over.emit()
