@tool
extends Node2D

const TILES_PER_ROOM = 8

@export var data: Room:
	set(value):
		data = value
		


@onready var walls = %Walls

func _ready() -> void:
	_build_room()
	

func _build_room() -> void:
	assert(data != null)
	
	var width = TILES_PER_ROOM * data.width
	var height = TILES_PER_ROOM * data.height
	
	var room_cells: Array[Vector2i]
	for w in width:
		for h in height:
			room_cells.append(Vector2i(w,h))
	
	walls.set_cells_terrain_connect(room_cells, 0, 0)
