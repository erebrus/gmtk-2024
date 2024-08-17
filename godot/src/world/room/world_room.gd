extends Node2D

const TILES_PER_ROOM = 19

@export var data: Room:
	set(value):
		data = value
		


@export_category("Scenes")

@export var DoorScene: PackedScene


@onready var walls: TileMapLayer = %Walls
var doors: Dictionary
var tile_size: Vector2i

func _ready() -> void:
	assert(DoorScene != null)
	tile_size = walls.tile_set.tile_size
	_build_room()
	

func start_position(door: Door) -> Vector2i:
	assert(door in doors)
	return doors[door].player_position
	

func _build_room() -> void:
	assert(data != null)
	_build_walls()
	_build_doors()
	

func _build_walls() -> void:
	Logger.info("Creating room of size %s" % data.size)
	
	var room_size = TILES_PER_ROOM * data.size
	
	var room_cells: Array[Vector2i]
	for w in room_size.x:
		for h in room_size.y:
			room_cells.append(Vector2i(w,h))
	
	walls.set_cells_terrain_connect(room_cells, 0, 0)
	

func _build_doors() -> void:
	Logger.info("Adding room doors")
	
	for door_data in data.doors:
		var door: Node2D = DoorScene.instantiate()
		door.data = door_data
		
		var door_x = door_data.cell.x * TILES_PER_ROOM * tile_size.x + tile_size.x / 2
		var door_y = door_data.cell.y * TILES_PER_ROOM * tile_size.y + tile_size.y / 2
		
		match door_data.side:
			Vector2i.UP:
				door_x += TILES_PER_ROOM * 0.5 * tile_size.x
			Vector2i.DOWN: 
				door_x += TILES_PER_ROOM * 0.5 * tile_size.x
				door_y += (TILES_PER_ROOM - 1) * tile_size.y
			Vector2i.LEFT:
				door_y += (TILES_PER_ROOM - 1) * 0.5 * tile_size.y
			Vector2i.RIGHT:
				door_x += (TILES_PER_ROOM - 1) * tile_size.x
				door_y += (TILES_PER_ROOM - 1) * 0.5 * tile_size.y
				
		door.position = Vector2(door_x, door_y)
		add_child(door)
		
		doors[door_data] = door
		door.door_entered.connect(_on_door_entered.bind(door_data))
	

func _on_door_entered(door: Door) -> void:
	Logger.info("entered door")
	Events.door_entered.emit(data, door)
	
