extends Node

@export var current_dungeon: Dungeon
@export var use_test_level:bool = true


@onready var dungeon: WorldDungeon = %WorldDungeon
@onready var blackout_overlay: Control = %BlackoutOverlay
@onready var player: Player = %Player

func _ready() -> void:
	blackout_overlay.show()
	dungeon.room_exited.connect(_on_room_exited)
	dungeon.room_loaded.connect(_on_room_loaded)
	dungeon.pre_room_load.connect(_on_pre_room_load)
	Events.timer_timeout.connect(func():Globals.do_game_over())
	
	if not use_test_level:
		Globals.levels[Globals.current_level].generate()
		current_dungeon = Globals.levels[Globals.current_level].dungeon
		current_dungeon.complete_gen()
	dungeon.enter(current_dungeon)
	var time = Globals.levels[Globals.current_level].time
	if time > 0:
		%Timer.time=time
		%Timer.visible=true
		%Timer.start()

	

func _on_room_loaded(player_position: Vector2i) -> void:
	player.position = player_position
	await get_tree().create_timer(0.2).timeout
	blackout_overlay.hide()
	
func _on_pre_room_load(room:Room):
	var room_size:Vector2i = room.size*Globals.TILES_PER_ROOM*Globals.TILE_SIZE
	%Camera2D.position = room_size/2
	
func _on_room_exited() -> void:
	blackout_overlay.show()
	player.global_position = Vector2(-1000, -1000)
