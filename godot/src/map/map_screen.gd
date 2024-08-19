extends Node


@export var evaluate_on_changed = false

@export_category("Score")
@export var min_accuracy = {
	"E"= 0.3,
	"D"= 0.5,
	"C"= 0.7,
	"B"= 0.8,
	"A"= 0.9,
	"S"= 0.999,
}

@export var passing_grade := "C"

@export var bonus_time = {
	"E"= 0,
	"D"= 0,
	"C"= 0,
	"B"= 0,
	"A"= 0,
	"S"= 0,
}

var target_dungeon: Dungeon

@onready var dungeon: MapDungeon = %MapDungeon

@onready var rooms_radio = %RoomsRadio
@onready var landmarks_radio = %LandmarksRadio

@onready var panels: Dictionary = {
	Types.MapMode.Rooms: %RoomsContainer,
	Types.MapMode.Doors: %DoorsContainer,
	Types.MapMode.Landmarks: %LandmarksContainer
}

func _ready() -> void:
	Events.map_changed.connect(_on_map_changed)
	target_dungeon = Globals.dungeon
	rooms_radio.button_pressed = true
	

func _on_map_mode_toggled(map_mode: Types.MapMode) -> void:
	if map_mode == Globals.map_mode:
		return
	
	Logger.info("Change to map mode %s" % Types.MapMode.keys()[map_mode])
	Globals.map_mode = map_mode
	for m in panels:
		panels[m].visible = map_mode == m
	

func _on_map_changed() -> void:
	if evaluate_on_changed:
		Logger.info("Map changed. Evaluating...")
		var score = dungeon.evaluate()
		Logger.info("Score: %s/%s" % [score, target_dungeon.max_score])
	

func _on_evaluate_button_pressed():
	%EvaluationPopup.show()
	var max_score = target_dungeon.max_score
	var score = dungeon.evaluate()
	Logger.info("Score: %s/%s" % [score, max_score])
	
	var factor = score / max_score
	var letter = "F"
	Logger.info("%s" % factor)
	for letter_score in min_accuracy:
		if factor > min_accuracy[letter_score]:
			letter = letter_score
	
	%ScoreLabel.text = letter
	

func _on_continue_button_pressed():
	Globals.next_level() 


func _on_retry_button_pressed():
	# TODO: retry same level
	Globals.start_game()
