@tool
class_name WorldRoom extends Node2D

signal door_entered(door: WorldDoor)


@export var cell: Vector2i
@export var size: Vector2i


@export_category("Scenes")

@export var DoorScene: PackedScene


var walls: TileMapLayer
var tile_size: Vector2i
var doors: Array[WorldDoor]


func _ready() -> void:
	assert(DoorScene != null)
	position = Vector2.ZERO
	

func build(room_data: Room) -> void:
	walls = %Walls
	tile_size = walls.tile_set.tile_size
	cell = room_data.cell
	size = room_data.size
	
	_build_walls()
	
	for door_data in room_data.doors:
		_add_door(door_data.cell, door_data.side)
	

func door_at(global_cell: Vector2i, side: Vector2i) -> WorldDoor:
	var local_cell = global_cell - cell
	for door in doors:
		if local_cell == door.cell and side == door.side:
			return door
	assert(false, "Could not find door at %s facing %s" % [global_cell, side])
	return null
	

func _build_walls() -> void:
	Logger.info("Creating room of size %s" % size)
	
	var room_size = Globals.TILES_PER_ROOM * size
	
	var room_cells: Array[Vector2i]
	for w in room_size.x:
		for h in room_size.y:
			room_cells.append(Vector2i(w,h))
	
	walls.set_cells_terrain_connect(room_cells, 0, 0)
	

func _add_door(cell: Vector2i, side: Vector2i) -> void:
	var door = DoorScene.instantiate()
	door.room = self
	door.cell = cell
	door.side = side
	doors.append(door)
	
	door.door_entered.connect(_on_door_entered.bind(door))
	
	%Doors.add_child(door)
	

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
