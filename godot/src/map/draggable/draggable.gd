class_name Draggable extends Node2D

signal started
signal dragged(to_global_position: Vector2)
signal dropped(to_global_position: Vector2)


const GROUP = &"draggable"


var is_about_to_drag = false
var is_dragging = false
var start_position: Vector2
var is_valid_position: Callable = func(x): return true


func _init() -> void:
	add_to_group(GROUP)
	

func _ready() -> void:
	Events.map_mode_changed.connect(drop)
	

func start(from_global_position: Vector2) -> void:
	if _other_is_dragging():
		return
		
	is_about_to_drag = true
	start_position = from_global_position
	

func _start() -> void:
	is_about_to_drag = false
	is_dragging = true
	started.emit()
	

func drop() -> void:
	if not is_dragging:
		return
	
	is_dragging = false
	if is_valid_position.call(get_global_mouse_position()):
		dropped.emit(get_global_mouse_position())
	else:
		dropped.emit(start_position)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.pressed:
		if is_about_to_drag:
			is_about_to_drag = false
		if is_dragging:
			drop()
	
	if event is InputEventMouseMotion:
		if is_about_to_drag:
			_start()
		
		if is_dragging:
			dragged.emit(get_global_mouse_position())
	

func _other_is_dragging() -> bool:
	for draggable in get_tree().get_nodes_in_group(GROUP):
		if draggable.is_dragging or draggable.is_about_to_drag:
			return true
	return false
	

func _on_map_mode_changed() -> void:
	if Globals.map_mode == Types.MapMode.Doors:
		drop()
	
