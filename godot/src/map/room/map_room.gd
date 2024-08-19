class_name MapRoom extends Area2D

signal dropped


@export var size: Vector2i:
	set(value):
		if value.x < 1 or value.y < 1:
			return
		size = value
		_calculate_size()
	

@export_category("Scenes")
@export var DoorScene: PackedScene

var dungeon: MapDungeon
var cell: Vector2i
	

var is_start_room:= false
var doors: Array[MapDoor]
var landmarks: Array[MapLandmark]
var drag_cell: Vector2i


@onready var draggable: Draggable = $Draggable
@onready var walls: NinePatchRect = $Walls
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var door_container: Node2D = $Doors


func _ready() -> void:
	_calculate_size()
	draggable.started.connect(_on_drag_started)
	draggable.dragged.connect(_on_dragged)
	draggable.dropped.connect(_on_dropped)
	
	for x in size.x:
		_add_door(Vector2i(x, 0), Vector2i.UP)
		_add_door(Vector2i(x, size.y -1), Vector2i.DOWN)
		
	for y in size.y:
		_add_door(Vector2i(0, y), Vector2i.LEFT)
		_add_door(Vector2i(size.x - 1, y), Vector2i.RIGHT)
	

func any_cell(filter: Callable) -> bool:
	for x in size.x:
		for y in size.y:
			if filter.call(cell + Vector2i(x,y)):
				return true
	return false
	

func activate_door(cell: Vector2i, side: Vector2i, start_door: bool = false) -> void:
	var door = _find_door(cell, side)
	assert(door != null)
	door.has_door = true
	door.is_start_door = start_door
	

func add_landmark(landmark: MapLandmark) -> void:
	if landmarks.has(landmark):
		return
	
	landmarks.append(landmark)
	landmark.room = self
	

func remove_landmark(landmark: MapLandmark) -> void:
	landmarks.erase(landmark)
	

func evaluate(target: Room, score: MapScore) -> void:
	score.check_room_exists(true)
	score.check_room_size(target.size == size)
	for drawn_door in doors:
		var valid_door = drawn_door.has_door == target.has_door(drawn_door.cell, drawn_door.side)
		score.check_doors(valid_door)
	
	# TODO: landmarks
	

func _add_door(door_cell: Vector2i, side: Vector2i) -> void:
	var door: MapDoor = DoorScene.instantiate()
	door.place(door_cell, side)
	doors.append(door)
	door_container.add_child(door)
	

func _find_door(door_cell: Vector2i, side: Vector2i) -> MapDoor:
	for door in doors:
		if door.cell == door_cell and door.side == side:
			return door
	return null
	

func _calculate_size() -> void:
	if walls == null or collision_shape == null:
		return
	
	walls.custom_minimum_size = size * Globals.MAP_CELL_SIZE
	var shape = RectangleShape2D.new()
	shape.size = size * Globals.MAP_CELL_SIZE
	collision_shape.shape = shape
	door_container.position = -size * Globals.MAP_CELL_SIZE * 0.5
	

func _move_to(to_global_position: Vector2) -> void:
	var drop_cell = dungeon.cell_from_global_position(to_global_position)
	cell = drop_cell - drag_cell
	_move_to_cell()
	

func _move_to_cell() -> void:
	var drop_position = dungeon.cell_to_global_position(cell)
	global_position = drop_position + size * Globals.MAP_CELL_SIZE * 0.5
	

func _on_drag_started() -> void:
	Logger.info("Started dragging room from cell %s" % drag_cell)
	modulate.a = 0.5
	

func _on_dragged(to_global_position: Vector2) -> void:
	_move_to(to_global_position)
	

func _on_dropped(to_global_position: Vector2) -> void:
	_move_to(to_global_position)
	Logger.info("Dropped room at cell %s (%s)" % [cell, to_global_position])
	modulate.a = 1
	for landmark in landmarks:
		landmark.cell = dungeon.cell_from_global_position(landmark.global_position)
	
	dropped.emit()
	Events.map_changed.emit()
	

func _on_input_event(_viewport, event: InputEvent, _shape_idx) -> void:
	if is_start_room:
		return
	if Globals.map_mode != Types.MapMode.Rooms:
		return
	
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			draggable.start(global_position)
			var global_cell = dungeon.cell_from_global_position(get_global_mouse_position())
			drag_cell = global_cell - cell
