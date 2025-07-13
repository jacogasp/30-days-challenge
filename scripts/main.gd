extends Node

var spawned_enemies: int = 0
var defeated_enemies: int = 0

@onready var l_enemy_spawner: Node2D = $GamePlane/LEnemySpawner
@onready var r_enemy_spawner: Node2D = $GamePlane/REnemySpawner
@onready var hud: CanvasLayer = $Hud
@onready var overboard_sailors: Node2D = $GamePlane/OverboardSailors
@onready var player: Player = $GamePlane/Player
@onready var pause_screen: Control = $Hud/Pause_Screen


func _ready() -> void:
	player.connect("update_sailors_count", update_sailors_count.bind())
	l_enemy_spawner.connect("enemy_spawned", enemy_spawned)
	r_enemy_spawner.connect("enemy_spawned", enemy_spawned)
	l_enemy_spawner.connect("enemy_defeated", enemy_defeated)
	r_enemy_spawner.connect("enemy_defeated", enemy_defeated)
	l_enemy_spawner.connect("overboard", overboard.bind())
	r_enemy_spawner.connect("overboard", overboard.bind())


func enemy_spawned():
	spawned_enemies += 1
	hud.update_spawned_enemies_label(spawned_enemies)


func enemy_defeated():
	defeated_enemies += 1
	hud.update_defeated_enemies_label(defeated_enemies)


func overboard(sailor: Sailor, g_pos: Vector2):
	overboard_sailors.add_child(sailor)
	sailor.set_overboard()
	sailor.global_position = g_pos


func update_sailors_count(count: int) -> void:
	hud.update_current_sailors_label(count)


func _on_player_game_over() -> void:
	const GAME_OVER_SCREEN = preload("res://scenes/game_over_screen.tscn")
	var game_over_screen = GAME_OVER_SCREEN.instantiate()
	hud.add_child(game_over_screen)
