extends Node

var world_speed: float = 500

var tick_score: int = 5 # Score per tick
var hit_score: int = 10 # Score per successful hit
var sink_score: int = 100 # Score per sinked ship
var sailor_score: int = 50 # Score per collected sailor

var tick_score_multiplier: int # Multiplier to be added to tick score
var hit_score_multiplier: int # Multiplier to be added to hit score
var sink_score_multiplier: int # Multiplier to be added to sink score
var sailor_score_multiplier: int # Multiplier to be added to sailor score

var player: Player
var player_livreaA: int = 1
var player_livreaB: int = 1
var player_livreaColor: int = 0

var colors: Array[Color] = [Color.DARK_RED, Color.NAVY_BLUE, Color.DARK_GREEN, Color.HOT_PINK, Color.ORANGE, Color.DIM_GRAY]

var sound_enabled: bool = true
var music_enabled: bool = true

var api_key = ""

func _ready() -> void:
	load_env()
	reset_score_multipliers()


func reset_score_multipliers() -> void:
	tick_score_multiplier = 1
	hit_score_multiplier = 1
	sink_score_multiplier = 1
	sailor_score_multiplier = 1


func load_env() -> void:
	var config = ConfigFile.new()
	var err = config.load("res://.env")
	if err != OK:
		print("Failed to load secrets.cfg file")
		return
	api_key = config.get_value("", "api_key")
