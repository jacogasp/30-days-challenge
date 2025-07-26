extends Control


@export var score: int = 42

@onready var score_label: Label = $Panel/MarginContainer/VBoxContainer/Score;
@onready var entries_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/ScrollContainer/Entries;
@onready var username: LineEdit = $Panel/MarginContainer/VBoxContainer/Username;

@onready var entry_label: PackedScene = preload("res://addons/talo/samples/leaderboards/entry.tscn")

var LEADERBOARD = "30 Days Challenge"


func _ready() -> void:
	score_label.text = "Your score: %d" % score
	await _load_entries()


func _create_entry(entry: TaloLeaderboardEntry) -> void:
	# var label = entry_label.instantiate();
	var label = Label.new()
	label.text = "%d. %s %d" % [entry.position, entry.player_alias.identifier, entry.score]
	entries_container.add_child(label)


func _build_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	for entry in Talo.leaderboards.get_cached_entries(LEADERBOARD):
		_create_entry(entry)


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
