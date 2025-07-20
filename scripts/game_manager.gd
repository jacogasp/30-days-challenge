extends Node2D

var spawned_enemies: int = 0
var defeated_enemies: int = 0
var _consecutive_kill_count: int = 0
var _hit_count: float = 0
var _game_is_running: bool = false
var _high_score: int = 0
var _score: float = 0
var _current_score: int = 0
var _difficulty_growth_base: float = 0.11
var _difficulty: int = 1
var _hit_count_decrease_rate: float = 10

@onready var last_hit_timer: Timer

const POPUP_SCORE = preload("res://scenes/huds/popup_score.tscn")

signal enemy_just_spawned
signal enemy_just_defeated
signal hit_count_updated
signal sailor_count_updated
signal score_updated
signal difficulty_changed
signal game_over


func _ready() -> void:
	last_hit_timer = Timer.new()
	last_hit_timer.wait_time = 3
	last_hit_timer.one_shot = true
	add_child(last_hit_timer)


func _process(delta: float) -> void:
	if not _game_is_running:
		return
	if last_hit_timer.time_left == 0 && _hit_count > 0:
		_hit_count -= _hit_count_decrease_rate * delta
		hit_count_updated.emit(hit_count(), false)
			
		
	_score += Globals.tick_score * Globals.tick_score_multiplier * delta
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
	if Globals.player != null:
		for node in Globals.player.get_parent().get_children():
			if node is Sailor or node is Barrel:
				node.queue_free()
	Globals.reset_score_multipliers()
	last_hit_timer.stop()
	spawned_enemies = 0
	defeated_enemies = 0
	_current_score = 0
	_score = 0
	_difficulty = 1


func current_score() -> int:
	return _current_score


func high_score() -> int:
	return _high_score


func hit_count() -> int:
	return ceil(_hit_count)


func _update_difficulty() -> void:
	var difficulty: int = ceil(_difficulty_growth_base * sqrt(_score))
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
	_hit_count = ceil(_hit_count + 1)
	hit_count_updated.emit(hit_count())
	last_hit_timer.start()
	score_updated.emit(current_score())


func player_hit() -> void:
	_hit_count = 0
	_consecutive_kill_count = 0
	hit_count_updated.emit(_hit_count, false)
	last_hit_timer.stop()


func enemy_defeated() -> void:
	defeated_enemies += 1
	_consecutive_kill_count += 1
	_score += Globals.sink_score * Globals.sink_score_multiplier * _consecutive_kill_count
	score_updated.emit(current_score())
	enemy_just_defeated.emit(defeated_enemies)


func get_sailor_score() -> void:
	_score += Globals.sailor_score * Globals.sailor_score_multiplier
	score_updated.emit(current_score())


func update_sailors_count(count: int) -> void:
	Globals.tick_score_multiplier = ceil(count / 5.0)
	Globals.world_speed = 500 + ((count - 5) * 40)
	sailor_count_updated.emit(count)


func overboard_sailor(sailor: Sailor, sailor_position: Vector2) -> void:
	Globals.player.add_sibling(sailor)
	sailor.set_overboard()
	sailor.global_position = sailor_position


func update_all_hud() -> void:
	difficulty_changed.emit(current_difficulty())
	hit_count_updated.emit(hit_count())
	score_updated.emit(current_score())


func spawn_enemy_defeated_score(pos: Vector2) -> void:
	var popup_score = POPUP_SCORE.instantiate()
	popup_score.value = Globals.sink_score * Globals.sink_score_multiplier * _consecutive_kill_count
	popup_score.global_position = pos
	Globals.player.add_sibling(popup_score)


func spawn_sailor_loaded_score(pos: Vector2) -> void:
	var popup_score = POPUP_SCORE.instantiate()
	popup_score.value = Globals.sailor_score * Globals.sailor_score_multiplier
	popup_score.global_position = pos
	Globals.player.add_sibling(popup_score)


func _game_over() -> void:
	stop()
	var is_new_high_score = false
	if current_score() > _high_score:
		_high_score = current_score()
		is_new_high_score = true
	game_over.emit(is_new_high_score)
