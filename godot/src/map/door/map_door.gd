class_name MapDoor extends Area2D

var cell: Vector2i
var side: Vector2i


var has_door:= false:
	set(value):
		has_door = value
		_toggle_door()


@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_build()
	_toggle_door()
	

func place(_cell: Vector2i, _side: Vector2i) -> void:
	cell = _cell
	side = _side

func _build() -> void:
	rotation = Vector2(side).angle() + PI / 2
	position = Vector2(cell) * Globals.MAP_CELL_SIZE
	
	match side:
		Vector2i.UP:
			position.x += 0.5 * Globals.MAP_CELL_SIZE
			position.y += sprite.get_rect().size.y * 0.5
		Vector2i.DOWN: 
			position.x += 0.5 * Globals.MAP_CELL_SIZE
			position.y += Globals.MAP_CELL_SIZE - sprite.get_rect().size.y * 0.5
		Vector2i.LEFT:
			position.x += sprite.get_rect().size.y * 0.5
			position.y += 0.5 * Globals.MAP_CELL_SIZE
		Vector2i.RIGHT:
			position.x += Globals.MAP_CELL_SIZE - sprite.get_rect().size.y * 0.5
			position.y += 0.5 * Globals.MAP_CELL_SIZE

func _toggle_door() -> void:
	sprite.visible = has_door


func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx):
	if Globals.map_mode != Types.MapMode.Doors:
		return
	
	if event.is_action_released("left_click"):
		has_door = !has_door
		_viewport.set_input_as_handled()
