class_name Door extends Resource

@export var cell: Vector2i
@export var side: Vector2i


var target: Door

func _to_string() -> String:
	return "door %s-%s" % [cell, side]
