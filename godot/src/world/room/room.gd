class_name Room extends Resource

@export var cell: Vector2i = Vector2i.ZERO
@export var size: Vector2i = Vector2i(1,1)

@export var doors: Array[Door]

@export var trap:Types.Traps
@export var landmark:Landmark
@export var hint:Hint

var doors_by_cell: Dictionary


func _to_string() -> String:
	return "%sx%s room at %s (%s,%s,%s). Doors:%s " % [
		size.x,
		size.y,
		cell,
		trap, landmark, hint,
		doors
	]


func build() -> bool:
	doors_by_cell.clear()
	
	for door in doors:
		if not _is_valid_door(door.cell, door.side):
			Logger.error("Door not valid position in room at room %s, cell %s, direction %s" % [cell, door.cell, door.side])
			return false
		
		if not doors_by_cell.has(door.cell):
			doors_by_cell[door.cell] = {}
		
		if doors_by_cell[door.cell].has(door.side):
			Logger.error("Room at %s has two doors at cell %s, direction %s" % [cell, door.cell, door.side])
			return false
		
		doors_by_cell[door.cell][door.side] = door
	
	return true
	

func get_cells()->Array:
	var ret := []
	for x in range(size.x):
		for y in range(size.y):
			ret.append(cell+Vector2i(x,y))
	return ret
	

func door_at(global_cell: Vector2i, side: Vector2i) -> Door:
	var local_cell = global_cell - cell
	var door = _find_door(local_cell, side)
	assert(door != null, "Could not find door at %s facing %s" % [global_cell, side])
	return door
	

func has_door(local_cell: Vector2i, side: Vector2i) -> bool:
	return _find_door(local_cell, side) != null
	

func _find_door(local_cell: Vector2i, side: Vector2i) -> Door:
	if doors_by_cell.has(local_cell) and doors_by_cell[local_cell].has(side):
		return doors_by_cell[local_cell][side]
	return null
	

func _is_valid_door(door_cell: Vector2i, door_side: Vector2i):
	if door_cell.x < 0 or door_cell.x >= size.x or door_cell.y < 0 or door_cell.y >= size.y:
		return false
	
	match door_side:
		Vector2i.UP:
			return door_cell.y == 0
		Vector2i.DOWN:
			return door_cell.y == size.y - 1
		Vector2i.LEFT:
			return door_cell.x == 0
		Vector2i.RIGHT:
			return door_cell.x == size.x - 1
	
	return false
