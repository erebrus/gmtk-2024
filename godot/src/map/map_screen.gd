extends Control

const LandmarkButton = preload("res://src/map/landmark/landmark_button.tscn")


@export var evaluate_on_changed = false
var target_dungeon: Dungeon

@onready var dungeon: MapDungeon = %MapDungeon

@onready var rooms_radio = %RoomsRadio
@onready var landmarks_radio = %LandmarksRadio

@onready var panels: Dictionary = {
	Types.MapMode.Rooms: %RoomsPanel,
	Types.MapMode.Doors: %DoorsPanel,
	Types.MapMode.Landmarks: %LandmarksPanel
}
@onready var landmark_container: Container = %LandmarkContainer
@onready var click_sfx: AudioStreamPlayer = %ClickSFX


func _ready() -> void:
	Events.map_changed.connect(_on_map_changed)
	Events.button_clicked.connect(_on_button_clicked)
	target_dungeon = Globals.dungeon
	rooms_radio.button_pressed = true
	Globals.map_mode = Types.MapMode.Rooms
	
	
	for button in landmark_container.get_children():
		button.visible = _is_found_landmark(button.landmark_type)
	

func _is_found_landmark(type: Types.Landmarks) -> bool:
	for landmark in target_dungeon.found_landmarks:
		if landmark.type == type:
			return true
			
	return false

func _on_map_mode_toggled(map_mode: Types.MapMode) -> void:
	if map_mode == Globals.map_mode:
		return
	
	Events.button_clicked.emit()
	Logger.info("Change to map mode %s" % Types.MapMode.keys()[map_mode])
	Globals.map_mode = map_mode
	for m in panels:
		panels[m].visible = map_mode == m
	

func _on_map_changed() -> void:
	if evaluate_on_changed:
		Logger.info("Map changed. Evaluating...")
		var score = dungeon.evaluate()
		Logger.info("Score: %s" % score)
	

func _on_evaluate_button_pressed():
	Events.button_clicked.emit()
	var score = dungeon.evaluate()
	Logger.info("Score: %s" % score)
	Events.map_scored.emit(score)
	

func _on_button_clicked() -> void:
	click_sfx.play()
	
