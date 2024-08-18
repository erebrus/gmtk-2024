extends Node2D

const position_delta=Vector2i(250, 100)
@onready var room_container: Node2D = $RoomContainer

var room_scene:PackedScene= preload("res://src/map/room/map_room.tscn")

@onready var x_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/XTextEdit
@onready var y_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/YTextEdit
@onready var min_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/MinTextEdit
@onready var max_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/MaxTextEdit
@onready var p_1x_1_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/P1x1TextEdit
@onready var p_1x_2_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/P1x2TextEdit
@onready var p_2x_1_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/P2x1TextEdit
@onready var p_2x_2_text_edit: TextEdit = $CanvasLayer/Panel/VBoxContainer/GridContainer/P2x2TextEdit
@onready var block_check_box: CheckBox = $CanvasLayer/Panel/VBoxContainer/GridContainer/BlockCheckBox

@onready var generator: BlockGenerator = $Generator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_ui()
	seed(1)
	
	generate()

func _update_ui():
	x_text_edit.text="%d" % generator.size.x
	y_text_edit.text="%d" % generator.size.y
	min_text_edit.text="%f" % generator.min_coverage
	max_text_edit.text="%f" % generator.max_coverage
	p_1x_1_text_edit.text="%d" % generator.s1x1_count
	p_1x_2_text_edit.text="%d" % generator.s1x2_count
	p_2x_1_text_edit.text="%d" % generator.s2x1_count
	p_2x_2_text_edit.text="%d" % generator.s2x2_count
	block_check_box.button_pressed = generator.block_limit
func generate():
	generator.generate()	

	draw_dungeon()			



func draw_dungeon():
	while room_container.get_child_count() > 0:
		room_container.remove_child(room_container.get_child(0))
	for room in generator.dungeon.rooms:
		var world_room:MapRoom = room_scene.instantiate()
		world_room.size=room.size
		room_container.add_child(world_room)
		world_room.global_position=Globals.MAP_CELL_SIZE*room.cell+position_delta+room.size*Globals.MAP_CELL_SIZE/2
		for d in room.doors:
			world_room.activate_door(d.cell, d.side)
		

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


func _on_p_2x_2_text_edit_focus_exited() -> void:
	generator.s2x2_count = clamp(int(p_2x_2_text_edit.text), 0,20)
	_update_ui()


func _on_p_2x_1_text_edit_focus_exited() -> void:
	generator.s2x1_count = clamp(int(p_2x_1_text_edit.text), 0,20)
	_update_ui()


func _on_p_1x_2_text_edit_focus_exited() -> void:
	generator.s1x2_count = clamp(int(p_1x_2_text_edit.text), 0,20)
	_update_ui()


func _on_p_1x_1_text_edit_focus_exited() -> void:
	generator.s1x1_count = clamp(int(p_1x_1_text_edit.text), 0,20)
	_update_ui()


func _on_block_check_box_toggled(toggled_on: bool) -> void:
	generator.block_limit=toggled_on
