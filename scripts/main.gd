extends Node

var spawned_enemies: int = 0
var defeated_enemies: int = 0

func _ready() -> void:
	$LEnemySpanwer.connect("enemy_spawned", enemy_spawned)
	$REnemySpanwer.connect("enemy_spawned", enemy_spawned)
	$LEnemySpanwer.connect("enemy_defeated", enemy_defeated)
	$REnemySpanwer.connect("enemy_defeated", enemy_defeated)


func enemy_spawned():
	spawned_enemies += 1
	$Hud.update_spawned_enemies_label(spawned_enemies)


func enemy_defeated():
	defeated_enemies += 1
	$Hud.update_defeated_enemies_label(defeated_enemies)
