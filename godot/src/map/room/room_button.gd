@tool extends DraggableButton


@export var room_size:= Vector2i(1,1):
	set(value):
		room_size = value
		custom_minimum_size = room_size * Globals.MAP_CELL_SIZE
	

func _create_scene() -> Node:
	var room: MapRoom = super._create_scene()
	room.size = room_size
	dungeon.add_room.call_deferred(room)
	
	return room
	
