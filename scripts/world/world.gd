extends Node2D

@onready var foreground: Parallax2D = $Foreground
@onready var sea: Parallax2D = $Sea


func _process(delta):
	var scrolling_speed = -Globals.world_speed
	sea.scroll_offset.x += scrolling_speed * delta * 0.7
	foreground.scroll_offset.x += scrolling_speed * delta
