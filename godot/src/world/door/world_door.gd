extends Area2D


@export var data: Door


func _ready() -> void:
	match data.side:
		Vector2i.UP:
			rotation = 0
		Vector2i.DOWN: 
			rotation = PI
		Vector2i.LEFT:
			rotation = PI/2
		Vector2i.RIGHT:
			rotation = -PI/2
