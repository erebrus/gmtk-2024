class_name Landmark extends Resource

@export var type:Types.Landmarks
@export var position:Vector2
@export var found:bool = false
var built := false


func _to_string() -> String:
	return str(type)
