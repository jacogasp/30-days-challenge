extends Node2D

@export var scrolling_speed:float = -500
@onready var foreground: Parallax2D = $Foreground
@onready var sea: Parallax2D = $Sea


func _process(delta):
	sea.scroll_offset.x += scrolling_speed * delta * 0.7
	foreground.scroll_offset.x += scrolling_speed * delta
