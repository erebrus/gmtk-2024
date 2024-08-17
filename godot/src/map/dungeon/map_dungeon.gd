class_name MapDungeon extends Node2D


func add_room(room: MapRoom) -> void:
	add_child(room)
	# FIXME find free space
	room._on_dropped(global_position + Vector2(20, 10) * Globals.TILE_SIZE)
