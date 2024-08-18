class_name Dungeon extends Resource

@export var size:= Vector2i(4,4)
@export var rooms: Array[Room]

var rooms_by_cell: Dictionary

func build() -> bool:
	rooms_by_cell.clear()
	
	for room in rooms:
		if not _map_room_cells(room):
			return false
		
	
	for room in rooms:
		if not _check_room_doors(room):
			return false
	
	if not _check_start_room_leads_outside():
		return false
	
	return true
	

func _map_room_cells(room: Room) -> bool:
	for x in room.size.x:
		for y in room.size.y:
			var cell = room.cell + Vector2i(x,y)
			if rooms_by_cell.has(cell):
				Logger.error("cell is already occupied by another room")
				return false
			
			rooms_by_cell[cell] = room
	return true
	

func _check_room_doors(room: Room) -> bool:
	var at_least_one_door:= false
	for door in room.doors:
		var target_cell = room.cell + door.cell + door.side
		if rooms_by_cell.has(target_cell):
			var target_room = rooms_by_cell[target_cell]
			var target_door = target_room.door_at(target_cell, -door.side)
			door.target = target_door
			at_least_one_door = true
	
	if not at_least_one_door:
		Logger.error("every room should have at least one door leading to another room")
		return false
		
	return true
	

func _check_start_room_leads_outside() -> bool:
	var start_room = rooms.front()
	var start_door = start_room.doors.front()
	var target_cell = start_room.cell + start_door.cell + start_door.side
	
	if rooms_by_cell.has(target_cell):
		Logger.error("start door should not lead to another room")
		return false
	return true
	

func get_room_for_cell(cell:Vector2i)->Room:
	if rooms_by_cell.has(cell):
		return rooms_by_cell[cell]
	return null;
	

func has_room_for_cell(cell:Vector2i)->bool:
	return rooms_by_cell.has(cell)
