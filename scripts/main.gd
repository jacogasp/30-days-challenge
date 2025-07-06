extends Node

var spawned_enemies: int = 0
var defeated_enemies: int = 0
@onready var l_enemy_spanwer: Node2D = $GamePlane/LEnemySpanwer
@onready var r_enemy_spanwer: Node2D = $GamePlane/REnemySpanwer
@onready var hud: CanvasLayer = $Hud

func _ready() -> void:
	l_enemy_spanwer.connect("enemy_spawned", enemy_spawned)
	r_enemy_spanwer.connect("enemy_spawned", enemy_spawned)
	l_enemy_spanwer.connect("enemy_defeated", enemy_defeated)
	r_enemy_spanwer.connect("enemy_defeated", enemy_defeated)


func enemy_spawned():
	spawned_enemies += 1
	hud.update_spawned_enemies_label(spawned_enemies)


func enemy_defeated():
	defeated_enemies += 1
	hud.update_defeated_enemies_label(defeated_enemies)
