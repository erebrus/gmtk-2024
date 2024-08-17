class_name Room extends Resource

@export var position: Vector2i = Vector2i.ZERO
@export var size: Vector2i = Vector2i(1,1)

@export var doors: Array[Door]


func global_door_cell(door: Door) -> Vector2i:
	assert(doors.has(door))
	return position + door.cell
	

func door_at(global_cell: Vector2i, side: Vector2i):
	var local_cell = global_cell - position
	for door in doors:
		if local_cell == door.cell and side == door.side:
			return door
	Logger.error("Could not find door at %s facing %s" % [global_cell, side])
	return null
	

func _to_string() -> String:
	return "%sx%s room at %s. %s Doors." % [
		size.x,
		size.y,
		position,
		doors.size()
	]
