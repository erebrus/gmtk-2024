class_name DungeonGenerator extends Node

var dungeon:Dungeon

func generate() -> void:
	dungeon = Dungeon.new()
	pass

		
static func generate_door(cell:Vector2i, side:Vector2i)->Door:
		var door:Door = Door.new()
		door.cell = cell
		door.side = side
		return door
		
static func generate_room_for_spec(size:Vector2i, position:Vector2i)->Room:
	var room:Room = Room.new()
	room.size=size
	room.cell=position
	return room
