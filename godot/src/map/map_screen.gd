extends Node


@export_category("Scenes")
@export var RoomScene: PackedScene
@export var DoorScene: PackedScene


@onready var dungeon: MapDungeon = %MapDungeon


func _ready() -> void:
	assert(RoomScene != null)
	assert(DoorScene != null)
	
	%Room1x1.pressed.connect(_add_room_pressed.bind(Vector2i(1,1)))
	%Room2x1.pressed.connect(_add_room_pressed.bind(Vector2i(2,1)))
	%Room1x2.pressed.connect(_add_room_pressed.bind(Vector2i(1,2)))
	%Room2x2.pressed.connect(_add_room_pressed.bind(Vector2i(2,2)))
	

func _add_room_pressed(size: Vector2i) -> void:
	var room = RoomScene.instantiate()
	room.size = size
	dungeon.add_room(room)
	
