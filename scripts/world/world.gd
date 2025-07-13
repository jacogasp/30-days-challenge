extends Node2D

@onready var foreground: Parallax2D = $Foreground
@onready var sea1: Parallax2D = $Sea1
@onready var sky: Sprite2D = $Sky
@onready var sun: Sprite2D = $Sky/Sun

func _ready():
	
	var set_sky = [_set_dawn, _set_day, _set_sunset]
	var index = randi() % set_sky.size()
	set_sky[index].call() # Call the randomly selected function

func _set_sunset() -> void:
	var sky_texture: GradientTexture2D = sky.texture
	sky_texture.gradient = load("res://assets/world/sunset_sky.tres")
	sun.scale = Vector2(0.5,0.5)
	sun.position = Vector2(580,100)
	sun.modulate = Color.ORANGE_RED
	sun.material.set_shader_parameter("blur_start", 0.65)
	sun.material.set_shader_parameter("fade_strenght", 1)
	sun.material.set_shader_parameter("blur_distance", 0.3)

func _set_dawn() -> void:
	var sky_texture: GradientTexture2D = sky.texture
	sky_texture.gradient = load("res://assets/world/dawn_sky.tres")
	sun.scale = Vector2(1,1)
	sun.position = Vector2(580,120)
	sun.modulate = Color.WHITE
	sun.material.set_shader_parameter("blur_start", 0.4)
	sun.material.set_shader_parameter("fade_strenght", 1)
	sun.material.set_shader_parameter("blur_distance", 0.3)		

func _set_day() -> void:
	var sky_texture: GradientTexture2D = sky.texture
	sky_texture.gradient = load("res://assets/world/day_sky.tres")
	sun.scale = Vector2(0.6,0.6)
	sun.position = Vector2(580,6)
	sun.modulate = Color(2,2,2)
	sun.material.set_shader_parameter("blur_start", 1)
	sun.material.set_shader_parameter("fade_strenght", 1)
	sun.material.set_shader_parameter("blur_distance", 1)		

func _process(delta) -> void:
	var scrolling_speed = -Globals.world_speed
	sea1.scroll_offset.x += scrolling_speed * delta * 0.7
	foreground.scroll_offset.x += scrolling_speed * delta
