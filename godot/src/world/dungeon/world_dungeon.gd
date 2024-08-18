class_name WorldDungeon extends Node2D

signal room_loaded(player_position: Vector2i)
signal room_exited


@export_category("Scenes")
@export var RoomScene: PackedScene

var current_room: WorldRoom
var rooms: Array[WorldRoom]

func _ready() -> void:
	assert(RoomScene != null)
	

func enter(dungeon: Dungeon) -> void:
	Globals.dungeon = dungeon
	assert(dungeon.build())
	_build(dungeon)
	
	var room = rooms.front()
	var door = room.doors.front()
	_enter_room(door)
	

func _enter_room(door: WorldDoor) -> void:
	Logger.info("Entering room: %s" % door.room)
	
	if current_room != null:
		remove_child(current_room)
	current_room = door.room
	door.room.request_ready()
	add_child.call_deferred(door.room)
	await door.room.ready
	room_loaded.emit(door.player_position)
	

func _build(data: Dungeon) -> void:
	var rooms_by_cell: Dictionary
	for room_data in data.rooms:
		var room: WorldRoom = RoomScene.instantiate()
		rooms.append(room)
		
		room.build(room_data)
		room.door_entered.connect(_on_door_entered)
		
		for x in room.size.x:
			for y in room.size.y:
				var cell = room.cell + Vector2i(x,y)
				assert(not rooms_by_cell.has(cell), "cell is already occupied by another room")
				rooms_by_cell[cell] = room
		
	for room in rooms:
		var at_least_one_door:= false
		for door in room.doors:
			if rooms_by_cell.has(door.target_cell):
				var target_room = rooms_by_cell[door.target_cell]
				var target_door = target_room.door_at(door.target_cell, -door.side)
				door.target = target_door
				at_least_one_door = true
		assert(at_least_one_door, "every room should have at least one door leading to another room")
	

func _on_door_entered(door: WorldDoor) -> void:
	Events.on_transition_state_change.emit(true)
	room_exited.emit()
	if door.target == null:
		Logger.info("Exit found!")
		Globals.go_to_map()
	else:
		Logger.info("Room entered")
		_enter_room(door.target)
	Events.on_transition_state_change.emit(false)
