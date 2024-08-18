extends Node

@export var current_dungeon: Dungeon


@onready var dungeon: WorldDungeon = %WorldDungeon
@onready var blackout_overlay: Control = %BlackoutOverlay
@onready var player: Player = %Player


func _ready() -> void:
	blackout_overlay.show()
	dungeon.room_exited.connect(_on_room_exited)
	dungeon.room_loaded.connect(_on_room_loaded)
	
	dungeon.enter(current_dungeon)
	

func _on_room_loaded(player_position: Vector2i) -> void:
	player.position = player_position
	player.in_animation = false
	await get_tree().create_timer(0.2).timeout
	blackout_overlay.hide()
	

func _on_room_exited() -> void:
	blackout_overlay.show()
	player.global_position = Vector2(-1000, -1000)
	player.in_animation = true
