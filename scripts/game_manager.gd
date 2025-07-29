extends Node2D

enum BarrelType {
	TNT,
	PRIMARY,
	SECONDARY
}

var spawned_enemies: int = 0
var defeated_enemies: int = 0
var visible_enemies: int = 0
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
var bomb_count: int = 1
var power_level: int = 1
var playback: AudioStreamPlaybackInteractive

const MAX_BOMB_COUNT: int = 5
const MAX_POWER_LEVEL: int = 4

# Barrel drop chances for enemy boats
var base_barrel_tnt_chance: float = 1.1
var base_barrel_primary_chance: float = 0.4
var base_barrel_secondary_chance: float = 0.2

enum SquidState {hidden, submitted, pending, alive, failed}
var _squid_state: SquidState = SquidState.hidden

@onready var last_hit_timer: Timer = $LastHitTimer
@onready var bomb_timer: Timer = $BombTimer
@onready var audio_player: AudioStreamPlayer = $Soundtrack
@onready var squid_enter_timer: Timer = $SquidEnterTimer


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
signal squid_submitted
signal squid_spawn
signal squid_exited

@export_group("Squid Timer")
@export var squid_first_shot_wait_time: float = 60
@export var squid_wait_time: float = 90

var t: float = 0

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
	
	t += delta
	if t > 2:
		print("Visible enemies %d" % visible_enemies)
		t = 0
	if _squid_state == SquidState.submitted && visible_enemies == 0:
		spawn_squid()


func start() -> void:
	_game_is_running = true
	_squid_state = SquidState.hidden
	if squid_enter_timer.is_stopped():
		print("Starting squid timer - game started")
		squid_enter_timer.start()
		play_soundtrack()


func stop() -> void:
	_game_is_running = false
	playback.switch_to_clip_by_name("Intro")
	squid_enter_timer.stop()
	print("Squid timer stopped")


func play_soundtrack() -> void:
	var stream: AudioStreamInteractive = audio_player.stream
	if stream.get_clip_name(playback.get_current_clip_index()) != "Soundtrack":
			playback.switch_to_clip_by_name("Soundtrack")


func reset() -> void:
	if Globals.player != null:
		for node in Globals.player.get_parent().get_children():
			if node is Sailor or node is Barrel:
				node.queue_free()
			if node.get_script() != null and "squid" in str(node.get_script().get_path()).to_lower():
				print("Cleaning up existing squid during reset")
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
	_difficulty_offset = 0
	_squid_state = SquidState.hidden
	squid_enter_timer.stop()
	squid_enter_timer.wait_time = squid_first_shot_wait_time
	if _game_is_running:
		squid_enter_timer.start()


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
	visible_enemies += 1
	enemy_just_spawned.emit(spawned_enemies)


func enemy_screen_exited() -> void:
	visible_enemies = max(0, visible_enemies - 1)


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


func enemy_defeated(mult: int = Globals.sink_score_multiplier) -> int:
	defeated_enemies += 1
	_consecutive_kill_count += 1
	var points: int = Globals.sink_score * mult * _consecutive_kill_count
	_score += points
	score_updated.emit(current_score())
	enemy_just_defeated.emit(defeated_enemies)
	return points


func get_sailor_score() -> int:
	var points: int = Globals.sailor_score * Globals.sailor_score_multiplier
	_score += points
	score_updated.emit(current_score())
	return points


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

func spaw_pickup_label(pos: Vector2, text: String) -> void:
	var popup_score = POPUP_SCORE.instantiate()
	popup_score.global_position = pos
	Globals.player.add_sibling(popup_score)
	popup_score.text = text
	popup_score.add_theme_font_override("font", load("res://assets/fonts/Bungee-Regular.ttf"))

func spawn_popup(text: String, pos: Vector2) -> void:
	var popup_score = POPUP_SCORE.instantiate()
	popup_score.global_position = pos
	Globals.player.add_sibling(popup_score)
	popup_score.text = text
	
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

func get_barrel_tnt_chance() -> float:
	return base_barrel_tnt_chance

func get_barrel_primary_chance() -> float:
	return base_barrel_primary_chance - (max(power_level - 1, 0)) * 0.05

func get_barrel_secondary_chance() -> float:
	return base_barrel_secondary_chance - (max(bomb_count - 1, 0)) * 0.05

func get_random_barrel_type() -> BarrelType:
	var barrel_tnt_chance = get_barrel_tnt_chance()
	var barrel_primary_chance = get_barrel_primary_chance()
	var barrel_secondary_chance = get_barrel_secondary_chance()
	var total_chance = barrel_primary_chance + barrel_secondary_chance + barrel_tnt_chance
	var random_roll: float = randf_range(0.0, total_chance)
	if random_roll <= barrel_tnt_chance:
		return BarrelType.TNT
	elif random_roll <= barrel_tnt_chance + barrel_primary_chance:
		return BarrelType.PRIMARY
	else:
		return BarrelType.SECONDARY

func spawn_barrel_at_position(barrel_type: BarrelType, spawn_position: Vector2) -> void:
	var barrel_scene: PackedScene
	match barrel_type:
		BarrelType.TNT:
			barrel_scene = preload("res://scenes/weapons/barrel.tscn")
		BarrelType.PRIMARY:
			barrel_scene = preload("res://scenes/weapons/barrel_primary.tscn")
		BarrelType.SECONDARY:
			barrel_scene = preload("res://scenes/weapons/barrel_secondary.tscn")
	var barrel: Barrel = barrel_scene.instantiate()
	barrel.global_position = spawn_position
	if Globals.player != null:
		Globals.player.add_sibling(barrel)


func _game_over() -> void:
	stop()
	var is_new_high_score = false
	if current_score() > _high_score:
		_high_score = current_score()
		is_new_high_score = true
	game_over.emit(is_new_high_score)


func _on_squid_enter_timer_timeout() -> void:
	# wait until all enemies exit the screen
	print("Squid timer fired, state: %d" % _squid_state)
	match _squid_state:
		SquidState.hidden, SquidState.failed:
			print("Squid submitted - attempting spawn")
			squid_submitted.emit()
			_squid_state = SquidState.submitted
		SquidState.alive:
			print("Squid already alive - skip")


func spawn_squid() -> void:
	if _squid_state != SquidState.submitted:
		squid_spawn_failed()
		return

	_squid_state = SquidState.pending
	print("Squid spawn pending")
	squid_spawn.emit()

	await get_tree().create_timer(5.0).timeout
	if _squid_state != SquidState.alive:
		print("Squid spawn timeout - no confirmation received, restarting timer")
		squid_spawn_failed()


func confirm_squid_spawned() -> void:
	_squid_state = SquidState.alive
	print("Squid spawn confirmed")


func squid_spawn_failed() -> void:
	print("Squid spawn failed - restarting timer")
	_squid_state = SquidState.failed
	squid_enter_timer.start()
	

func squid_defeated() -> void:
	_squid_state = SquidState.hidden
	print("Squid exited")
	squid_exited.emit()
	_difficulty_offset += round(float(_difficulty) * 0.15)
	_difficulty -= _difficulty_offset
	difficulty_changed.emit(current_difficulty())
	squid_enter_timer.wait_time = squid_wait_time
	squid_enter_timer.start()
