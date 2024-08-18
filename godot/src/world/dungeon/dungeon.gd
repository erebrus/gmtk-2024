class_name Dungeon extends Resource

@export var size:= Vector2i(4,4)
@export var rooms: Array[Room]

#TODO optimize? maybe store map
func get_room_for_cell(cell:Vector2i)->Room:
	for room in rooms:
		for x in room.size.x:
			for y in room.size.y:
				if cell == room.cell + Vector2i(x,y):
					return room
	return null;
				
func has_room_for_cell(cell:Vector2i)->bool:
	return get_room_for_cell(cell) != null
