@tool
class_name WorldRoom extends Node2D

signal door_entered(door: WorldDoor)

	#Vector2i(1,1):[
		#Vector2i.ONE*Globals.TILES_PER_ROOM*Globals.TILE_SIZE/2.0
	#]
#}
const LANDMARK_SCENES = [preload("res://src/world/room/landmarks/world_landmark.tscn")]

@export var cell: Vector2i
@export var size: Vector2i


@export_category("Scenes")

@export var DoorScene: PackedScene


var walls: TileMapLayer
var tile_size: Vector2i
var doors: Array[WorldDoor]

var landmark
var hint
var trap

func _ready() -> void:
	assert(DoorScene != null)
	

func build(room_data: Room) -> void:
	walls = %Walls
	tile_size = walls.tile_set.tile_size
	cell = room_data.cell
	size = room_data.size
	
	_build_walls()
	
	if room_data.landmark:
		_build_landmark(room_data.landmark)
		
	#if room_data.landmark:
	#	_build_landmark(room_data.landmark)
	#if room_data.trap:
		#_build_trap(room_data.trap)
	#if room_data.hint:
		#_build_hint()
	for door_data in room_data.doors:
		_add_door(door_data.cell, door_data.side)
		
	
	

func get_door(door: Door) -> WorldDoor:
	for d in doors:
		if d.cell == door.cell and d.side == door.side:
			return d
	
	assert(false, "Could not find door  %s" % door)
	return null
	

func _build_walls() -> void:
	Logger.info("Creating room of size %s" % size)
	
	var room_size = Globals.TILES_PER_ROOM * size
	
	var room_cells: Array[Vector2i]
	for w in room_size.x:
		for h in room_size.y:
			room_cells.append(Vector2i(w,h))
	
	walls.set_cells_terrain_connect(room_cells, 0, 0)
	
func get_room_pixel_size() -> Vector2:
	return size * Globals.TILE_SIZE * Globals.TILES_PER_ROOM


func _add_door(cell: Vector2i, side: Vector2i) -> void:
	var door = DoorScene.instantiate()
	door.room = self
	door.cell = cell
	door.side = side
	doors.append(door)
	
	door.door_entered.connect(_on_door_entered.bind(door))
	
	%Doors.add_child(door)
	
func _build_landmark(landmark_data:Landmark):
	landmark = LANDMARK_SCENES[0].instantiate()
	add_child(landmark)
	if not landmark_data.built:
		var pos:= (get_room_pixel_size()-Vector2.ONE*Globals.LANDMARK_SIZE*2)*randf()+Vector2.ONE*Globals.LANDMARK_SIZE 
		var attempt := 0
		while not is_landmark_position_valid(pos):
			attempt += 1
			pos = (get_room_pixel_size()-Vector2.ONE*Globals.LANDMARK_SIZE*2)*randf()+Vector2.ONE*Globals.LANDMARK_SIZE 		
			if attempt > 100:
				Logger.error("Failed to add landmark after 100 attempts. Setting middle of the room.")
				landmark.position = get_room_pixel_size()/2.0
				return
		if attempt > 10:
			Logger.info("Added landmark after %d" % attempt)
		landmark_data.position = pos
		landmark_data.built = true
		
	landmark.global_position = landmark_data.position
		
func is_landmark_position_valid(pos:Vector2)-> bool:
	if pos.x < Globals.LANDMARK_SIZE  or pos.y < Globals.LANDMARK_SIZE:
		return false
	
	if pos.x > get_room_pixel_size().x - Globals.LANDMARK_SIZE  or pos.y > get_room_pixel_size().y - Globals.LANDMARK_SIZE:
		return false
	
	for d in doors:
		if d.global_position.distance_to(pos) < Globals.LANDMARK_SIZE*2:
			return false
	return true


func _on_door_entered(door: WorldDoor) -> void:
	Logger.info("entered door")
	door_entered.emit(door)
	

func _to_string() -> String:
	return "%sx%s room at %s. %s Doors." % [
		size.x,
		size.y,
		cell,
		doors.size()
	]
