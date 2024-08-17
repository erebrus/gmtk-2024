extends Node

@onready var dungeon: WorldDungeon = %WorldDungeon
@onready var blackout_overlay: Control = %BlackoutOverlay
@onready var player: Node2D = %Player


func _ready() -> void:
	blackout_overlay.show()
	dungeon.room_loaded.connect(_on_room_loaded)
	
	dungeon.enter()
	

func _on_room_loaded(player_position: Vector2i) -> void:
	player.position = player_position
	await get_tree().create_timer(0.2).timeout
	blackout_overlay.hide()
	
