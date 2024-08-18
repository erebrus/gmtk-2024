class_name MapDungeon extends Node2D

const GRID_SIZE = Vector2i(10, 10)

var dungeon: Dungeon
var grid_offset: Vector2

func _ready() -> void:
	dungeon = Globals.dungeon
	var offset_cells: Vector2 = (GRID_SIZE - dungeon.size) / 2
	grid_offset = global_position + offset_cells * Globals.MAP_CELL_SIZE
	

func add_room(room: MapRoom) -> void:
	room.dungeon = self
	add_child(room)
	room.global_position = cell_to_global_position(room.cell) + room.size * Globals.MAP_CELL_SIZE * 0.5
	# FIXME find free space
	

func cell_from_global_position(global: Vector2) -> Vector2i:
	if global.x < grid_offset.x:
		global.x -= Globals.MAP_CELL_SIZE
	if global.y < grid_offset.y:
		global.y -= Globals.MAP_CELL_SIZE
	
	var grid_position: Vector2i = global - grid_offset
	return grid_position / Globals.MAP_CELL_SIZE
	

func cell_to_global_position(cell: Vector2i) -> Vector2:
	return grid_offset + Vector2(cell) * Globals.MAP_CELL_SIZE
	

#func _input(event) -> void:
	#var room: MapRoom
	#
	#if event is InputEventMouseMotion:
		#Logger.info("cell: %s" % cell_from_global_position(get_global_mouse_position()))
	
