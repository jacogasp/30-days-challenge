extends CanvasLayer


func update_spawned_enemies_label(count):
	$SpanwnedEnemiesLabel.text = "Spawned enemies %d" % count


func update_defeated_enemies_label(count):
	$DefeatedEnemiesLabel.text = "Defeated enemies %d" % count
