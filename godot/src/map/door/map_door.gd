class_name MapDoor extends Area2D

const GROUP = &"draggable"


var cell: Vector2i
var side: Vector2i
var is_start_door:= false
var room: MapRoom


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
	

func unset_door() -> void:
	has_door = false
	for door in get_overlapping_areas():
		if door is MapDoor:
			door.has_door = false
	

func set_if_facing_door() -> void:
	var target = _target_door()
	if target != null and target.has_door:
		has_door = true
	
	

func _copy_state_to_target_doors() -> void:
	var target = _target_door()
	Logger.info("copying state %s to target door %s" % [has_door, target])
	if target != null:
		target.has_door = has_door

func _target_door() -> MapDoor:
	return room.dungeon.find_door(room.cell + cell + side, -side)
	

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
	

func _on_input_event(viewport: Viewport, event: InputEvent, _shape_idx):
	if _is_dragging():
		return
	
	if event.is_action_released("left_click"):
		viewport.set_input_as_handled()
			
		has_door = !has_door
		_copy_state_to_target_doors()
		
		if has_door:
			$PlacedSFX.play()
		else:
			$RemovedSFX.play()
	
func _is_dragging() -> bool:
	for draggable in get_tree().get_nodes_in_group(GROUP):
		if draggable.is_dragging or draggable.is_about_to_drag:
			return true
	return false
	

func _to_string():
	return "%s -> %s" % [cell, cell+side]
