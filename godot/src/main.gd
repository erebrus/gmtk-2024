extends Node

@export var dungeon: Dungeon:
	set(value):
		dungeon = value
		if dungeon != null:
			_generate_map()
var rooms_map: Dictionary
var doors_map: Dictionary


@export_category("Scenes")
@export var RoomScene: PackedScene

var room: Node

@onready var room_container: Node2D = %RoomContainer
@onready var blackout_overlay: Control = %BlackoutOverlay
@onready var player: Node2D = %PlayerPlaceholder


func _ready() -> void:
	assert(RoomScene != null)
	
	Events.door_entered.connect(_go_through_door)
	var start_room = dungeon.rooms.front()
	var start_door = start_room.doors.front()
	_load_room(start_room, start_door)
	

func _load_room(data: Room, door: Door) -> void:
	Logger.info("Loading room: %s" % data)
	blackout_overlay.show()
	await get_tree().create_timer(0.1).timeout
	if room != null:
		room.queue_free()
	room = RoomScene.instantiate()
	room.data = data
	room_container.add_child.call_deferred(room)
	await room.ready
	player.position = room.start_position(door)
	await get_tree().create_timer(0.2).timeout
	blackout_overlay.hide()
	

func _generate_map() -> void:
	rooms_map.clear()
	for room in dungeon.rooms:
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
	
	
	
