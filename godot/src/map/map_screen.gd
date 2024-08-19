extends Control


@export var evaluate_on_changed = false
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
	Globals.map_mode = Types.MapMode.Rooms
	

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
		Logger.info("Score: %s" % score)
	

func _on_evaluate_button_pressed():
	var score = dungeon.evaluate()
	Logger.info("Score: %s" % score)
	Events.map_scored.emit(score)
	
