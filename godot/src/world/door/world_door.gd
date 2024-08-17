extends Area2D


signal door_entered


@export var data: Door


var player_position: Vector2i:
	get:
		return $PlayerPosition.global_position
	

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


func _on_body_entered(body):
	door_entered.emit()
