extends Node

var world_speed: float = 500

var current_score: float = 0
var high_score: float = 0

var tick_score: int = 1 # Score per seconds
var hit_score: int = 1 # Score per successful hit
var sink_score: int = 50 # Score per sinked ship
var sailor_score: int = 10 # Score per collected sailor

var tick_score_multiplier: int = 1 # Multiplier to be added to tick score
var hit_score_multiplier: int = 1 # Multiplier to be added to hit score
var sink_score_multiplier: int = 1 # Multiplier to be added to sink score
var sailor_score_multiplier: int = 1 # Multiplier to be added to sailor score
