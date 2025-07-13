extends Node2D

@onready var foreground: Parallax2D = $Foreground
@onready var skyline: Parallax2D = $Skyline
@onready var sea_1: Parallax2D = $Sea1
@onready var sea_2: Parallax2D = $Sea2
@onready var sea_3: Parallax2D = $Sea3
@onready var sea_4: Parallax2D = $Sea4
@onready var sea_5: Parallax2D = $Sea5
@onready var sky: Sprite2D = $Sky
@onready var sun: Sprite2D = $Sky/Sun

func _ready():
	var set_sky = [_set_dawn, _set_day, _set_sunset]
	var index = randi() % set_sky.size()
	skyline.scroll_offset.x = randf_range(0,2560)
	set_sky[index].call() # Call the randomly selected function

func _set_sunset() -> void:
	var sky_texture: GradientTexture2D = sky.texture
	sky_texture.gradient = load("res://assets/world/sunset_sky.tres")
	sun.scale = Vector2(0.6,0.6)
	sun.position = Vector2(580,80)
	sun.modulate = Color.ORANGE_RED
	sun.material.set_shader_parameter("blur_start_y", 0.65)
	sun.material.set_shader_parameter("fade_strength", 1)
	sun.material.set_shader_parameter("blur_distance", 0.3)

func _set_dawn() -> void:
	var sky_texture: GradientTexture2D = sky.texture
	sky_texture.gradient = load("res://assets/world/dawn_sky.tres")
	sun.scale = Vector2(1,1)
	sun.position = Vector2(580,120)
	sun.modulate = Color.WHITE
	sun.material.set_shader_parameter("blur_start_y", 0.4)
	sun.material.set_shader_parameter("fade_strength", 1)
	sun.material.set_shader_parameter("blur_distance", 0.3)		

func _set_day() -> void:
	var sky_texture: GradientTexture2D = sky.texture
	sky_texture.gradient = load("res://assets/world/day_sky.tres")
	sun.scale = Vector2(0.7,0.7)
	sun.position = Vector2(580,6)
	sun.modulate = Color(2,2,2)
	sun.material.set_shader_parameter("blur_start_y", 1)
	sun.material.set_shader_parameter("fade_strength", 1)
	sun.material.set_shader_parameter("blur_distance", 1)

func _process(delta) -> void:
	var scrolling_speed = -Globals.world_speed
	sea_1.scroll_offset.x += scrolling_speed * delta * 0.7
	sea_2.scroll_offset.x += scrolling_speed * delta * 0.4
	sea_3.scroll_offset.x += scrolling_speed * delta * 0.2
	sea_4.scroll_offset.x += scrolling_speed * delta * 0.1
	sea_5.scroll_offset.x += scrolling_speed * delta * 0.05
	skyline.scroll_offset.x += scrolling_speed * delta * 0.01
	foreground.scroll_offset.x += scrolling_speed * delta
