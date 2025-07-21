extends Barrel

func _on_area_entered(area: Area2D) -> void:
	# Interact only with player and its bullets
	if not exploding:
		var success:bool = false
		if area.get_parent() is Player:
			success = GameManager.gain_bomb()
		if success:
			_chaching()
		else:
			_explode()	

func _chaching():
	GameManager.spaw_bomb_gained_label(global_position)
	wave_particles.visible = false
	wave_particles.emitting = false
	sprite.visible = false
	set_process(false)
	set_physics_process(false)
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	audio_streamer.play()
	queue_free_timer.start()
	exploding = true
	
