class_name Draggable extends Node2D

signal started
signal dragged(to_global_position: Vector2)
signal dropped(to_global_position: Vector2)


const GROUP = &"draggable"


var is_dragging = false
var start_position: Vector2
var mouse_offset: Vector2
var is_valid_position: Callable = func(x): return true


func _init() -> void:
	add_to_group(GROUP)
	

func _ready() -> void:
	Events.map_mode_changed.connect(drop)
	

func start(from_global_position: Vector2) -> bool:
	if _other_is_dragging() or Globals.map_mode == Types.MapMode.Doors:
		return false
		
	is_dragging = true
	start_position = from_global_position
	mouse_offset = get_global_mouse_position() - global_position
	started.emit()
	return is_dragging
	

func drop() -> void:
	if not is_dragging:
		return
	
	is_dragging = false
	if is_valid_position.call(mouse_position()):
		dropped.emit(mouse_position())
	else:
		dropped.emit(start_position)
	

func mouse_position() -> Vector2:
	return get_global_mouse_position() - mouse_offset
	

func _input(event: InputEvent) -> void:
	if not is_dragging:
		return
	
	if event is InputEventMouseMotion:
		dragged.emit(get_global_mouse_position() - mouse_offset)
		
	
	if event is InputEventMouseButton:
		if not event.pressed:
			drop()
	

func _other_is_dragging() -> bool:
	for draggable in get_tree().get_nodes_in_group(GROUP):
		if draggable.is_dragging:
			return true
	return false
	

func _on_map_mode_changed() -> void:
	if Globals.map_mode == Types.MapMode.Doors:
		drop()
	
