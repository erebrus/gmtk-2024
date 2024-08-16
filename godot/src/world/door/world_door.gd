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


func _on_input_event(_viewport, event: InputEvent, _shape_idx):
	# FIXME: only clicable for debug purposes!!!
	if event.is_action_pressed("left_click"):
		door_entered.emit()
		
