class_name Room extends Resource

@export var cell: Vector2i = Vector2i.ZERO
@export var size: Vector2i = Vector2i(1,1)

@export var doors: Array[Door]

@export var trap:Types.Traps
@export var landmark:Types.Landmarks
@export var hint:bool

func _to_string() -> String:
	return "%sx%s room at %s (%s,%s,%s). Doors:%s " % [
		size.x,
		size.y,
		cell,
		trap, landmark, hint,
		doors
	]


func get_cells()->Array:
	var ret := []
	for x in range(size.x):
		for y in range(size.y):
			ret.append(cell+Vector2i(x,y))
	return ret
			
