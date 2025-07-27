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
var _difficulty_offset: int = 0
var _hit_count_decrease_rate: float = 10
var bomb_count: int = 0
var power_level: int = 1
var playback: AudioStreamPlaybackInteractive
var music_enabled: bool = true
var squid_alive: bool = false
const MAX_BOMB_COUNT: int = 5
const MAX_POWER_LEVEL: int = 4

@onready var last_hit_timer: Timer = $LastHitTimer
@onready var bomb_timer: Timer = $BombTimer
@onready var audio_player: AudioStreamPlayer = $Soundtrack
@onready var squid_enter_timer: Timer = $SquidEnterTimer
@onready var squid_exit_timer: Timer = $SquidExitTimer


const POPUP_SCORE = preload("res://scenes/huds/popup_score.tscn")

signal enemy_just_spawned
signal enemy_just_defeated
signal hit_count_updated
signal sailor_count_updated
signal score_updated
signal difficulty_changed
signal game_over
signal bomb_deployed
signal bomb_count_updated
signal power_level_updated
signal squid_entered
signal squid_exited


func _ready() -> void:
	playback = audio_player.get_stream_playback()


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
	if music_enabled:
		play_soundtrack()


func stop() -> void:
	_game_is_running = false
	playback.switch_to_clip_by_name("Intro")


func play_soundtrack() -> void:
	var stream: AudioStreamInteractive = audio_player.stream
	if stream.get_clip_name(playback.get_current_clip_index()) != "Soundtrack":
			playback.switch_to_clip_by_name("Soundtrack")


func reset() -> void:
	if Globals.player != null:
		for node in Globals.player.get_parent().get_children():
			if node is Sailor or node is Barrel:
				node.queue_free()
	Globals.reset_score_multipliers()
	last_hit_timer.stop()
	spawned_enemies = 0
	defeated_enemies = 0
	bomb_count = 0
	power_level = 1
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
	var difficulty: int = ceil(_difficulty_growth_base * sqrt(_score)) - _difficulty_offset
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
	if power_level > 1:
		power_level -= 1
		spaw_pickup_label(Globals.player.global_position, "-P")
		power_level_updated.emit(power_level)
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
	bomb_count_updated.emit(bomb_count)
	power_level_updated.emit(power_level)


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


func spaw_pickup_label(pos: Vector2, text: String) -> void:
	var popup_score = POPUP_SCORE.instantiate()
	popup_score.global_position = pos
	Globals.player.add_sibling(popup_score)
	popup_score.text = text
	popup_score.add_theme_font_override("font", load("res://assets/fonts/Bungee-Regular.ttf"))


func deploy_bomb() -> void:
	if bomb_timer.time_left > 0:
		return
	if bomb_count <= 0:
		bomb_count = 0
		return
	bomb_count -= 1
	bomb_timer.start()
	bomb_count_updated.emit(bomb_count)
	bomb_deployed.emit()


func gain_bomb() -> bool:
	if bomb_count < MAX_BOMB_COUNT:
		bomb_count += 1
		bomb_count_updated.emit(bomb_count)
		return true
	return false


func powerup() -> bool:
	if power_level < MAX_POWER_LEVEL:
		power_level += 1
		power_level_updated.emit(power_level)
		return true
	return false


func _game_over() -> void:
	stop()
	var is_new_high_score = false
	if current_score() > _high_score:
		_high_score = current_score()
		is_new_high_score = true
	game_over.emit(is_new_high_score)


func disable_music() -> void:
	music_enabled = false
	audio_player.stop()


func enable_music() -> void:
	music_enabled = true
	audio_player.play()


func _on_squid_enter_timer_timeout() -> void:
	squid_alive = true
	squid_exit_timer.start()
	squid_entered.emit()
	print("squid entered")
	

func _on_squid_exit_timer_timeout() -> void:
	squid_alive = false
	squid_enter_timer.start()
	squid_exited.emit()
	_difficulty_offset += round(float(_difficulty) * 0.25)
	_difficulty -= _difficulty_offset
	difficulty_changed.emit(current_difficulty())
	print("squid exited")
