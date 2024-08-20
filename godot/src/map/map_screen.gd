extends Control

const LandmarkButton = preload("res://src/map/landmark/landmark_button.tscn")
const RoomScene = preload("res://src/map/room/map_room.tscn")
const LandmarkScene = preload("res://src/map/landmark/map_landmark.tscn")

@export var evaluate_on_changed = false
var target_dungeon: Dungeon

@onready var dungeon: MapDungeon = %MapDungeon
@onready var solution: MapDungeon = %SolutionDungeon

@onready var landmark_container: Container = %LandmarkContainer
@onready var click_sfx: AudioStreamPlayer = %ClickSFX


func _ready() -> void:
	Events.map_changed.connect(_on_map_changed)
	Events.button_clicked.connect(_on_button_clicked)
	target_dungeon = Globals.dungeon
	
	for button in landmark_container.get_children():
		button.visible = _is_found_landmark(button.landmark_type)
	
	_create_solution_map()
	%SolutionDungeon.visible = false
	%SolutionOverlay.visible = false
	

func _create_solution_map() -> void:
	for room_data in target_dungeon.rooms:
		var room = RoomScene.instantiate()
		room.size = room_data.size
		room.cell = room_data.cell
		solution.add_room(room)
		room._move_to_cell()
		
		for door in room_data.doors:
			room.activate_door(door.cell, door.side)
		
		if room_data.landmark != null:
			var landmark = LandmarkScene.instantiate()
			landmark.landmark_type = room_data.landmark.type
			landmark.cell = room.cell
			solution.add_landmark(landmark)
			landmark._move_to_cell()
	

func _is_found_landmark(type: Types.Landmarks) -> bool:
	for landmark in target_dungeon.found_landmarks:
		if landmark.type == type:
			return true
			
	return false
	

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
	
	%SolutionDungeon.visible = false
	%SolutionOverlay.visible = true
	

func _on_button_clicked() -> void:
	click_sfx.play()
	

func _on_solution_overlay_gui_input(event:InputEvent):
	if event.is_action_pressed("left_click"):
		%SolutionDungeon.show()		
	if event.is_action_released("left_click"):
		%SolutionDungeon.hide()
