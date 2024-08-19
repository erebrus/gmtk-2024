extends Node

@export var current_dungeon: Dungeon
@export var levels: Array[BlockGenerator]
@export var use_test_level:bool = true
@export var debug_skip_eval:bool = false

@onready var dungeon: WorldDungeon = %WorldDungeon
@onready var blackout_overlay: Control = %BlackoutOverlay
@onready var player: Player = %Player

func _ready() -> void:
	blackout_overlay.show()
	dungeon.room_exited.connect(_on_room_exited)
	dungeon.room_loaded.connect(_on_room_loaded)
	dungeon.pre_room_load.connect(_on_pre_room_load)
	if not use_test_level:
		levels[0].generate()
		current_dungeon = levels[0].dungeon
	dungeon.enter(current_dungeon)
	

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
