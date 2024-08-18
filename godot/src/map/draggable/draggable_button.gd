class_name DraggableButton extends NinePatchRect

@export_node_path var dungeon_path: NodePath

@export_category("Scenes")
@export var Scene: PackedScene

@onready var dungeon: MapDungeon = get_node(dungeon_path)
@onready var draggable: Draggable = $Draggable


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	draggable.started.connect(_on_drag_started)
	

func _create_scene() -> Node:
	return Scene.instantiate()
	

func _on_scene_ready(scene: Node) -> void:
	scene.draggable._start()
	

func _on_drag_started() -> void:
	var scene = _create_scene()
	await scene.ready
	_on_scene_ready(scene)

func _on_gui_input(event: InputEvent):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			draggable.start(global_position)
