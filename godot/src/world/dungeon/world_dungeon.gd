class_name WorldDungeon extends Node2D

signal room_loaded(player_position: Vector2i)


@export var data: Dungeon:
	set(value):
		data = value
		if data != null:
			_generate_map()
var rooms_map: Dictionary
var doors_map: Dictionary


@export_category("Scenes")
@export var RoomScene: PackedScene

var room: Node


func _ready() -> void:
	assert(RoomScene != null)
	
	Events.door_entered.connect(_go_through_door)
	

func enter() -> void:
	var start_room = data.rooms.front()
	var start_door = start_room.doors.front()
	_load_room(start_room, start_door)
	

func _load_room(data: Room, door: Door) -> void:
	Logger.info("Loading room: %s" % data)
	
	if room != null:
		room.queue_free()
	room = RoomScene.instantiate()
	room.data = data
	add_child.call_deferred(room)
	await room.ready
	room_loaded.emit(room.start_position(door))
	

func _generate_map() -> void:
	rooms_map.clear()
	for room in data.rooms:
		for x in room.size.x:
			for y in room.size.y:
				rooms_map[room.position + Vector2i(x,y)] = room
	

func _go_through_door(room: Room, door: Door) -> void:
	var room_cell = room.global_door_cell(door) + door.side
	if rooms_map.has(room_cell):
		var next_room = rooms_map[room_cell]
		var next_door = next_room.door_at(room_cell, -door.side)
		_load_room(next_room, next_door)
	else:
		Logger.info("Exit found!")
	
	
