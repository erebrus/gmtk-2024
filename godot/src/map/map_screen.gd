extends Node


@export_category("Scenes")
@export var RoomScene: PackedScene
@export var DoorScene: PackedScene


var target_dungeon: Dungeon

@onready var dungeon: MapDungeon = %MapDungeon

@onready var rooms_radio = %RoomsRadio

@onready var panels: Dictionary = {
	Types.MapMode.Rooms: %RoomsContainer,
	Types.MapMode.Doors: %DoorsContainer
}

func _ready() -> void:
	assert(RoomScene != null)
	assert(DoorScene != null)
	
	Events.map_changed.connect(_on_map_changed)
	target_dungeon = Globals.dungeon
	rooms_radio.button_pressed = true
	
	%Room1x1.pressed.connect(_add_room_pressed.bind(Vector2i(1,1)))
	%Room2x1.pressed.connect(_add_room_pressed.bind(Vector2i(2,1)))
	%Room1x2.pressed.connect(_add_room_pressed.bind(Vector2i(1,2)))
	%Room2x2.pressed.connect(_add_room_pressed.bind(Vector2i(2,2)))
	
	_add_start_room()
	

func _add_start_room() -> void:
	var start_room = target_dungeon.rooms.front()
	var room: MapRoom = RoomScene.instantiate()
	room.size = start_room.size
	room.cell = start_room.cell
	room.is_start_room = true
	dungeon.add_room(room)
	
	var start_door = start_room.doors.front()
	room.activate_door(start_door.cell, start_door.side, true)
	

func _add_room_pressed(size: Vector2i) -> void:
	var room = RoomScene.instantiate()
	room.size = size
	dungeon.add_room(room)
	

func _on_map_mode_toggled(map_mode: Types.MapMode) -> void:
	if map_mode == Globals.map_mode:
		return
	
	Logger.info("Change to map mode %s" % Types.MapMode.keys()[map_mode])
	Globals.map_mode = map_mode
	for m in panels:
		panels[m].visible = map_mode == m
	

func _on_map_changed() -> void:
	Logger.info("Map changed. Evaluating...")
	var score = dungeon.evaluate()
	Logger.info("Score: %s" % score)
