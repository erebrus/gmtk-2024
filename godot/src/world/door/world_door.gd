class_name WorldDoor extends Area2D


signal door_entered


var cell: Vector2i
var side: Vector2i

var room: WorldRoom
var target: WorldDoor


var target_cell: Vector2i:
	get:
		return room.cell + cell + side
	

var player_position: Vector2i:
	get:
		return $PlayerPosition.global_position
	

func _ready() -> void:
	rotation = Vector2(side).angle() + PI / 2
	position = Vector2(cell) * Globals.TILES_PER_ROOM * Globals.TILE_SIZE + Vector2(0.5, 0.5) * Globals.TILE_SIZE
	
	match side:
		Vector2i.UP:
			position.x += Globals.TILES_PER_ROOM * 0.5 * Globals.TILE_SIZE
		Vector2i.DOWN: 
			position.x += Globals.TILES_PER_ROOM * 0.5 * Globals.TILE_SIZE
			position.y += (Globals.TILES_PER_ROOM - 1) * Globals.TILE_SIZE
		Vector2i.LEFT:
			position.y += (Globals.TILES_PER_ROOM - 1) * 0.5 * Globals.TILE_SIZE
		Vector2i.RIGHT:
			position.x += (Globals.TILES_PER_ROOM - 1) * Globals.TILE_SIZE
			position.y += (Globals.TILES_PER_ROOM - 1) * 0.5 * Globals.TILE_SIZE
	

func _enter_tree():
	$CollisionShape2D.disabled = false
	

func _exit_tree():
	$CollisionShape2D.disabled = true
	

func _on_body_entered(body):
	door_entered.emit()
