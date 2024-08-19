extends Node

@export var current_dungeon: Dungeon
@export var use_test_level:bool = true


@onready var dungeon: WorldDungeon = %WorldDungeon
@onready var blackout_overlay: Control = %BlackoutOverlay
@onready var player: Player = %Player

var last_door:Door

func _ready() -> void:
	blackout_overlay.show()
	dungeon.room_exited.connect(_on_room_exited)
	dungeon.room_loaded.connect(_on_room_loaded)
	dungeon.pre_room_load.connect(_on_pre_room_load)
	Events.timer_timeout.connect(func():Globals.do_game_over())
	Events.on_hint_found.connect(update_hud)
	Events.on_landmark_found.connect(func(x):update_hud())
	Events.confirmation_requested.connect(_on_confirmation_requested)
	if not use_test_level:
		if Globals.last_dungeon:
			current_dungeon=Globals.last_dungeon
		else:	
			Globals.levels[Globals.current_level].generate()
			current_dungeon = Globals.levels[Globals.current_level].dungeon
			current_dungeon.complete_gen()
	dungeon.enter(current_dungeon)
	update_hud()
	var time = Globals.levels[Globals.current_level].time
	if time > 0:
		%Timer.time=time
		%Timer.visible=true
		%Timer.start()

	
func update_hud():
	%Hud.update_rooms(Globals.dungeon.get_explored_room_count(), Globals.dungeon.rooms.size())
	%Hud.update_landmarks(Globals.dungeon.get_landmarks_count(true), Globals.dungeon.get_landmarks_count(false))
	%Hud.update_cheeses(Globals.dungeon.get_hint_count(true), Globals.dungeon.get_hint_count(false))
	
func _on_room_loaded(player_position: Vector2i) -> void:
	player.position = player_position
	await get_tree().create_timer(0.2).timeout
	blackout_overlay.hide()
	
	
func _on_pre_room_load(room:Room):
	update_hud()

	
func _on_room_exited() -> void:
	blackout_overlay.show()
	player.global_position = Vector2(-1000, -1000)


func _on_confirmation_requested(door:WorldDoor):
	%Player.in_animation = true
	%Player.velocity = Vector2.ZERO
	%Confirmation.visible = true
	
	for door_data in Globals.current_room.doors:
		if door_data.cell == door.cell and door_data.side == door.side:
			last_door = door_data
	
func _unhandled_input(event: InputEvent) -> void:
	if %Confirmation.visible:
		if Input.is_action_just_pressed("action"):
			Globals.go_to_map()
		elif Input.is_action_just_pressed("ui_cancel"):
			%Player.in_animation = false
			%Confirmation.visible = false		
			%WorldDungeon._enter_room(Globals.current_room, last_door)	
