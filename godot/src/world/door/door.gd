class_name Door extends Resource

@export var cell: Vector2i
@export var side: Vector2i

#func _init(_cell: Vector2i, _side: Vector2i) -> void:
	#cell = _cell
	#side = _side
