extends Barrel

func _on_area_entered(area: Area2D) -> void:
	# Interact only with player and its bullets
	if not exploding:
		var success:bool = false
		if area.get_parent() is Player:
			success = GameManager.powerup()
		if success:
			_pickup()
		else:
			_explode()	

func _pickup():
	GameManager.spaw_pickup_label(global_position, "P")
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
	
