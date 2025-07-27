extends Barrel

func _on_area_entered(area: Area2D) -> void:
	# Interact only with player and its bullets
	if not exploding:
		var success:bool = false
		if area.get_parent() is Player:
			success = GameManager.gain_bomb()
		if success:
			_pickup()
		else:
			_explode(area.is_in_group("bullet"))

func _pickup():
	GameManager.spaw_pickup_label(global_position, "S")
	wave_particles.visible = false
	wave_particles.emitting = false
	sprite.visible = false
	set_process(false)
	set_physics_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	hit_audio_player.play()
	queue_free_timer.start()
	exploding = true
