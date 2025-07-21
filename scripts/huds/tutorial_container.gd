extends VBoxContainer

@export var textures_move: Array[Texture]
@export var textures_fire: Array[Texture]
@export var textures_special: Array[Texture]

@onready var move_texture_rect: TextureRect = $HBoxContainer/MoveTextureRect
@onready var fire_texture_rect: TextureRect = $HBoxContainer2/FireTextureRect
@onready var special_texture_rect: TextureRect = $HBoxContainer3/SpecialTextureRect

var _move_index: int = 0
var _fire_index: int = 0
var _special_index: int = 0

func _ready() -> void:
	move_texture_rect.texture = textures_move[_move_index]
	
	fire_texture_rect.texture = textures_fire[_fire_index]
	special_texture_rect.texture = textures_special[_special_index]


func _on_close_timer_timeout() -> void:
	queue_free()


func _on_loop_timer_timeout() -> void:
	_move_index = wrapi(_move_index+1,0,textures_move.size())
	_fire_index =  wrapi(_fire_index+1,0,textures_fire.size())
	_special_index =  wrapi(_special_index+1,0,textures_special.size())
	move_texture_rect.texture = textures_move[_move_index]
	fire_texture_rect.texture = textures_fire[_fire_index]
	special_texture_rect.texture = textures_special[_special_index]
