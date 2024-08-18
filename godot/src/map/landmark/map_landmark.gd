class_name MapLandmark extends Area2D

signal dropped


var landmark_type: Types.Landmarks:
	set(value):
		if value == landmark_type:
			return
		landmark_type = value
		$Sprite2D.frame = (landmark_type-1)

var dungeon: MapDungeon
var cell: Vector2i
var room: MapRoom


@onready var draggable: Draggable = $Draggable


func _ready() -> void:
	draggable.started.connect(_on_drag_started)
	draggable.dragged.connect(_on_dragged)
	draggable.dropped.connect(_on_dropped)
	

func _on_drag_started() -> void:
	Logger.info("Started dragging landmark")
	modulate.a = 0.5
	

func _on_dragged(to_global_position: Vector2) -> void:
	_move_to(to_global_position)
	

func _on_dropped(to_global_position: Vector2) -> void:
	_move_to(to_global_position)
	Logger.info("Dropped room at cell %s (%s)" % [cell, to_global_position])
	modulate.a = 1
	dropped.emit()
	Events.map_changed.emit()
	

func _move_to(to_global_position: Vector2) -> void:
	cell = dungeon.cell_from_global_position(to_global_position)
	var drop_position = dungeon.cell_to_global_position(cell)
	global_position = drop_position + Globals.MAP_CELL_SIZE * Vector2(0.5, 0.5)
	
