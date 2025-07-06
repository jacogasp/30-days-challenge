extends Node

var spawned_enemies: int = 0
var defeated_enemies: int = 0
@onready var l_enemy_spanwer: Node2D = $GamePlane/LEnemySpanwer
@onready var r_enemy_spanwer: Node2D = $GamePlane/REnemySpanwer
@onready var hud: CanvasLayer = $Hud
@onready var overboard_sailors: Node2D = $GamePlane/OverboardSailors

func _ready() -> void:
	l_enemy_spanwer.connect("enemy_spawned", enemy_spawned)
	r_enemy_spanwer.connect("enemy_spawned", enemy_spawned)
	l_enemy_spanwer.connect("enemy_defeated", enemy_defeated)
	r_enemy_spanwer.connect("enemy_defeated", enemy_defeated)
	l_enemy_spanwer.connect("overboard", overboard.bind())
	r_enemy_spanwer.connect("overboard", overboard.bind())
	


func enemy_spawned():
	spawned_enemies += 1
	hud.update_spawned_enemies_label(spawned_enemies)


func enemy_defeated():
	defeated_enemies += 1
	hud.update_defeated_enemies_label(defeated_enemies)

func overboard(sailor:Sailor, g_pos: Vector2):
	overboard_sailors.add_child(sailor)
	sailor.set_overboard()
	sailor.global_position = g_pos
