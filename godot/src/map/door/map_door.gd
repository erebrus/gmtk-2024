class_name MapDoor extends Area2D

var cell: Vector2i
var side: Vector2i
var is_start_door:= false

var has_door:= false:
	set(value):
		if is_start_door:
			has_door = true
		else:
			has_door = value
		_toggle_door()


@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_build()
	_toggle_door()
	

func place(_cell: Vector2i, _side: Vector2i) -> void:
	cell = _cell
	side = _side
	

func get_target_door() -> MapDoor:
	var doors = get_overlapping_areas()
	assert(doors.size() < 2)
	if doors.is_empty():
		return null
	else:
		return doors.front()
	

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
	sprite.frame = 0 if has_door else 1
	Events.map_changed.emit()
	

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx):
	if Globals.map_mode != Types.MapMode.Doors:
		return
	
	if event.is_action_released("left_click"):
		has_door = !has_door
	

func _on_area_exited(area: Area2D) -> void:
	assert(area is MapDoor)
	has_door = false


func _on_area_entered(area: Area2D) -> void:
	assert(area is MapDoor)
	var door = area as MapDoor
	if door.has_door:
		has_door = true
	

func _to_string():
	return "%s -> %s" % [cell, cell+side]
