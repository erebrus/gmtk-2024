extends MarginContainer

const LEADERBOARD_KEY = "gmtk2024"
const ROW = preload("res://src/leaderboard_row.tscn")


@export var rows = 10

var is_highscore: bool
var is_top: bool = false
var old_player_name: String

@onready var leaderboard: Container = %LeaderboardContents

func _ready() -> void:
	%Leaderboard.hide()
	await get_tree().process_frame
	update()
	

func update():
	var items = await LootLocker.leaderboard.list(LEADERBOARD_KEY, rows, 0)
	Logger.info("Obtained items from lootlocker %s" % [items])
	
	var player = await LootLocker.leaderboard.get_player_score(LEADERBOARD_KEY)
	
	if player.rank > rows:
		items = items.slice(0, rows-1) + [player]
	
	if items.is_empty():
		return
	
	for child in leaderboard.get_children():
		child.hide()
		child.queue_free()
	
	for item in items:
		var row = ROW.instantiate()
		row.setup(item)
		leaderboard.add_child(row)
	
	%Leaderboard.show()
	

func submit_name(player_name: String):
	await LootLocker.player.set_name(player_name)
	update()

func _on_retry_button_pressed():
	Globals.in_game = true
	Globals.reset_game()


func _on_line_edit_text_submitted(new_text):
	submit_name(new_text)


func _on_submit_button_pressed():
	submit_name(%PlayerName.text)
