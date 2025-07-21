extends CanvasLayer

@onready var sailor_texture: TextureRect = %SailorTexture
@onready var current_sailors_label: Label = %CurrentSailorsLabel
@onready var high_score_label: Label = %HighScoreLabel
@onready var current_score_label: Label = %CurrentScoreLabel

@onready var hit_count: Control = %HitCount
@onready var hit_count_number_label: Label =%HitCount/NumberLabel
@onready var hit_count_text_label: Label = %HitCount/TextLabel

@onready var spawned_enemies_label: Label = $Control/DEBUGPanel/VBoxContainer/SpawnedEnemiesLabel
@onready var defeated_enemies_label: Label = $Control/DEBUGPanel/VBoxContainer/DefeatedEnemiesLabel
@onready var difficulty_label: Label = $Control/DEBUGPanel/VBoxContainer/DifficultyLabel

@onready var secondary_label: Label = %SecondaryLabel
@onready var current_secondary_label: Label = %CurrentSecondaryLabel
@onready var progress_bar: ProgressBar = %SecondaryLabel/ProgressBar

func _ready() -> void:
	GameManager.score_updated.connect(update_current_score_label)
	GameManager.sailor_count_updated.connect(update_current_sailors_label)
	GameManager.hit_count_updated.connect(update_hit_count_label)
	GameManager.enemy_just_defeated.connect(update_defeated_enemies_count)
	GameManager.enemy_just_spawned.connect(update_spawned_enemies_count)
	GameManager.difficulty_changed.connect(update_difficulty)
	GameManager.bomb_count_updated.connect(update_secondary_label)
	GameManager.bomb_timer.timeout.connect(secondary_reset)
	progress_bar.max_value = GameManager.bomb_timer.wait_time
	progress_bar.value = 0
	GameManager.update_all_hud()
	high_score_label.text = "HIGHSCORE: %09d" % GameManager.high_score()

func _process(_delta: float) -> void:
	if !GameManager.bomb_timer.is_stopped():
		progress_bar.value = GameManager.bomb_timer.time_left

func secondary_reset():
	bounce_control(secondary_label)

func update_secondary_label(count: int):
	if count <= 0:
		secondary_label.visible = false
		current_secondary_label.visible = false
	elif count == 1:
		secondary_label.visible = true
		current_secondary_label.visible = false
	else:
		secondary_label.visible = true
		current_secondary_label.visible = true
		current_secondary_label.text = str(count)
	bounce_control(sailor_texture)

func update_current_score_label(count: int):
	current_score_label.text = "SCORE: %09d" % count

func update_current_sailors_label(count: int):
	current_sailors_label.text = "%d" % count
	bounce_control(sailor_texture)

func update_defeated_enemies_count(count: int):
	defeated_enemies_label.text = "Deafeted En:%d"%count

func update_spawned_enemies_count(count: int):
	spawned_enemies_label.text = "Spawned En:%d"%count

func update_difficulty(count:int):
	difficulty_label.text = "Difficulty:%d"%count

func update_hit_count_label(count: int, increasing:bool = true):
	hit_count_number_label.text = str(count)
	if count == 0:
		hit_count_number_label.visible = false
		hit_count_text_label.visible = false
		return
	else:
		hit_count_number_label.visible = true
		hit_count_text_label.visible = true
	hit_count_text_label.text = "Hit" if count == 1 else "Hits"
	const BASE_FONT_SIZE = 32
	const MAX_FONT_SIZE = 64 
	const SCALING_COUNT_MAX = 100 
	var number_font_size = BASE_FONT_SIZE
	var text_font_size = BASE_FONT_SIZE
	if count > 1:
		var clamped_count = clampi(count, 1, SCALING_COUNT_MAX)
		var progress = float(clamped_count - 1) / (SCALING_COUNT_MAX - 1)
		number_font_size = lerp(BASE_FONT_SIZE, MAX_FONT_SIZE, progress)
		text_font_size = lerp(BASE_FONT_SIZE, MAX_FONT_SIZE, progress)
	if count > 100:
		hit_count_text_label.text = "Hits!!!"
		number_font_size = 64 
		text_font_size = 48 
	hit_count_number_label.add_theme_font_size_override("font_size", int(number_font_size))
	hit_count_text_label.add_theme_font_size_override("font_size", int(text_font_size))
	if increasing:
		bounce_control(hit_count)

func bounce_control(control:Control):
	var bounce_tween = create_tween()
	var bounce_duration = 0.2
	var bounce_scale = Vector2(1.2, 1.2)
	var bounce_rotation_degrees = 5.0
	bounce_tween.tween_property(control, "scale", bounce_scale, bounce_duration / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(control, "rotation_degrees", bounce_rotation_degrees, bounce_duration / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	bounce_tween.tween_property(control, "scale", Vector2(1, 1), bounce_duration / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	bounce_tween.tween_property(control, "rotation_degrees", 0.0, bounce_duration / 2.0)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
