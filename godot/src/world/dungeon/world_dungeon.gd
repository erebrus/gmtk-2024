class_name WorldDungeon extends Node2D

signal room_loaded(player_position: Vector2i)
signal pre_room_load(room:Room)
signal room_exited


@export_category("Scenes")
@export var RoomScene: PackedScene

var current_room: WorldRoom
var rooms: Array[WorldRoom]

func _ready() -> void:
	assert(RoomScene != null)
	

func enter(dungeon: Dungeon) -> void:
	Globals.dungeon = dungeon
	Globals.last_dungeon = dungeon.duplicate()
	assert(dungeon.build())
	dungeon.start_room.explored=true
	pre_room_load.emit(dungeon.start_room)
	_enter_room(dungeon.start_room, dungeon.start_door)
	

func _enter_room(room_data: Room, door_data: Door) -> void:
	Logger.info("Entering room: %s" % room_data)
	
	if current_room != null:
		current_room.queue_free()
	Globals.current_room=room_data
	await get_tree().create_timer(0.2).timeout
	
	var door = _create_door(room_data, door_data)
	await door.room.ready
	room_loaded.emit(door.player_position)
	Events.on_transition_state_change.emit(false)
	

func _create_door(room_data: Room, door_data: Door) -> WorldDoor:
	current_room = RoomScene.instantiate()
	current_room.build(room_data)
	current_room.door_entered.connect(_on_door_entered)
	add_child.call_deferred(current_room)
	
	return current_room.get_door(door_data)
	
	
func _on_door_entered(door: WorldDoor) -> void:
	Events.on_transition_state_change.emit(true)
	room_exited.emit()
	var target_cell = door.target_cell
	var target_room: Room = Globals.dungeon.get_room_for_cell(target_cell)
	if target_room == null:
		if Globals.debug_skip_eval:			
			Globals.next_level()
		else:
			Logger.info("Exit found!")
			Events.confirmation_requested.emit(door)
			#Globals.go_to_map()
	else:
		target_room.explored = true
		pre_room_load.emit(target_room)
		var target_door = target_room.door_at(target_cell, -door.side)
		_enter_room(target_room, target_door)
