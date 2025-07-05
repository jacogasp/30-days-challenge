extends Node

var spawned_enemies: int = 0

func _ready() -> void:
	$LEnemySpanwer.connect("enemy_spawned", enemy_spawned)
	$REnemySpanwer.connect("enemy_spawned", enemy_spawned)

func enemy_spawned():
	spawned_enemies += 1
	$Hud.update_spawned_enemies_label(spawned_enemies)
