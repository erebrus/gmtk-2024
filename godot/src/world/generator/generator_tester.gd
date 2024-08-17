extends Node2D

const position_delta=Vector2i.ONE*256
@onready var room_container: Node2D = $RoomContainer

var room_scene:PackedScene= preload("res://src/map/room/map_room.tscn")

@onready var x_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/XTextEdit
@onready var y_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/YTextEdit
@onready var min_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/MinTextEdit
@onready var max_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/MaxTextEdit

@onready var generator: BlockGenerator = $Generator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_ui()
	
	generate()

func _update_ui():
	x_text_edit.text="%d" % generator.size.x
	y_text_edit.text="%d" % generator.size.y
	min_text_edit.text="%f" % generator.min_coverage
	max_text_edit.text="%f" % generator.max_coverage
	
func generate():
	generator.generate()	
	for y in range(generator.size.y):
		var row=" ."
		for x in range(generator.size.x):
			if generator.matrix[x][y]==null:
				row+=" "
			else:
				row+= "%2d." % generator.dungeon.rooms.find(generator.matrix[x][y])
		print(row)
	draw_dungeon()			



func draw_dungeon():
	while room_container.get_child_count() > 0:
		room_container.remove_child(room_container.get_child(0))
	for room in generator.dungeon.rooms:
		var world_room:MapRoom = room_scene.instantiate()
		world_room.size=room.size
		room_container.add_child(world_room)
		world_room.global_position=Globals.TILE_SIZE*room.cell+position_delta+room.size*Globals.TILE_SIZE/2
		

#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("ui_accept"):
		#generate()


func _on_x_text_edit_focus_exited() -> void:
	generator.size.x=int(x_text_edit.text)
	_update_ui()


func _on_y_text_edit_focus_exited() -> void:
	generator.size.y=int(y_text_edit.text)
	_update_ui()


func _on_min_text_edit_focus_exited() -> void:
	generator.min_coverage = clamp(float(min_text_edit.text), 0.1,1.0)
	_update_ui()


func _on_max_text_edit_focus_exited() -> void:
	generator.max_coverage = clamp(float(max_text_edit.text), 0.1,1.0)
	_update_ui()

func _on_button_pressed() -> void:
	generate()
