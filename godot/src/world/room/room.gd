class_name Room extends Resource

@export var cell: Vector2i = Vector2i.ZERO
@export var size: Vector2i = Vector2i(1,1)

@export var doors: Array[Door]


func _to_string() -> String:
	return "%sx%s room at %s. Doors:%s " % [
		size.x,
		size.y,
		cell,
		doors
	]


func get_cells()->Array:
	var ret := []
	for x in range(size.x):
		for y in range(size.y):
			ret.append(cell+Vector2i(x,y))
	return ret
			

func door_at(global_cell: Vector2i, side: Vector2i) -> Door:
	var local_cell = global_cell - cell
	for door in doors:
		if local_cell == door.cell and side == door.side:
			return door
	assert(false, "Could not find door at %s facing %s" % [global_cell, side])
	return null
	
