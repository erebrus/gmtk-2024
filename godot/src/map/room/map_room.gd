class_name MapRoom extends Area2D


@export var size: Vector2i:
	set(value):
		if value.x < 1 or value.y < 1:
			return
		size = value
		_calculate_size()
	

@onready var draggable: Draggable = $Draggable
@onready var walls: NinePatchRect = $Walls
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	_calculate_size()
	draggable.started.connect(_on_drag_started)
	draggable.dragged.connect(_on_dragged)
	draggable.dropped.connect(_on_dropped)
	

func _calculate_size() -> void:
	if walls == null or collision_shape == null:
		return
	
	walls.custom_minimum_size = size * Globals.TILE_SIZE
	var shape = RectangleShape2D.new()
	shape.size = size * Globals.TILE_SIZE
	collision_shape.shape = shape
	

func _move_to(to_global_position: Vector2) -> void:
	var x:float = int(to_global_position.x) / Globals.TILE_SIZE
	var y:float = int(to_global_position.y) / Globals.TILE_SIZE
	
	if size.x % 2:
		x += 0.5
	if size.y % 2:
		y += 0.5
	
	global_position = Vector2(x,y) * Globals.TILE_SIZE
	
	

func _on_drag_started() -> void:
	Logger.info("Started dragging room")
	modulate.a = 0.5
	

func _on_dragged(to_global_position: Vector2) -> void:
	_move_to(to_global_position)
	

func _on_dropped(to_global_position: Vector2) -> void:
	Logger.info("Dropped room at %s" % to_global_position)
	_move_to(to_global_position)
	modulate.a = 1
	

func _on_input_event(_viewport, event: InputEvent, _shape_idx) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			draggable.start(global_position)
