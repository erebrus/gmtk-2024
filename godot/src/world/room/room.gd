class_name Room extends Resource

@export var cell: Vector2i = Vector2i.ZERO
@export var size: Vector2i = Vector2i(1,1)

@export var doors: Array[Door]


func _to_string() -> String:
	return "%sx%s room at %s. %s Doors." % [
		size.x,
		size.y,
		cell,
		doors.size()
	]


func get_cells()->Array:
	var ret := []
	for x in range(size.x):
		for y in range(size.y):
			ret.append(cell+Vector2i(x,y))
	return ret
			
