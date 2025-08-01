extends Panel


@export var score: int = 42

@onready var score_label: Label = $MarginContainer/VBoxContainer/Score;
@onready var entries: ItemList = $MarginContainer/VBoxContainer/ScrollContainer/Entries

@onready var entry_label: PackedScene = preload("res://addons/talo/samples/leaderboards/entry.tscn")
@onready var return_button: Button = $MarginContainer/VBoxContainer/ReturnButton

var LEADERBOARD = "30 Days Challenge"
signal return_pressed

func _ready() -> void:
	if GameManager.current_score() == 0:
		score_label.text = "High Score: %d" % GameManager.high_score()
	else:
		score_label.text = "Current Score: %d" % GameManager.current_score()
	return_button.grab_focus()
	await _load_entries()

func _create_entry(entry: TaloLeaderboardEntry) -> void:
	var item_text = "%d. %s %d" % [entry.position + 1, entry.player_alias.identifier, entry.score]
	entries.add_item(item_text)


func _build_entries() -> void:
	entries.clear()
	for entry in Talo.leaderboards.get_cached_entries(LEADERBOARD):
		_create_entry(entry)
	for i in range(0,entries.get_item_count()):
		entries.set_item_tooltip_enabled(i,false)


func _load_entries() -> void:
	var page = 0
	var done = false

	while !done:
		var options := Talo.leaderboards.GetEntriesOptions.new()
		options.page = page

		var res = await Talo.leaderboards.get_entries(LEADERBOARD, options)
		if res.is_last_page:
			done = true
		else:
			page += 1

	_build_entries()


func _on_return_button_pressed() -> void:
	return_pressed.emit()
