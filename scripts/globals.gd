extends Node

var world_speed: float = 500

var hit_score: int # Score per successful hit
var sink_score: int # Score per sinked ship
var sailor_score: int # Score per collected sailor

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

func _ready() -> void:
	reset_score()


func reset_score() -> void:
	hit_score = 1
	sink_score = 50
	sailor_score = 10

	tick_score_multiplier = 1
	hit_score_multiplier = 1
	sink_score_multiplier = 1
	sailor_score_multiplier = 1
