class_name DungeonGenerator extends Resource

@export var size:Vector2i = Vector2i(4,4)
@export var hint_ratio := .2
@export var trap_ratio := .1
@export var landmark_ratio := .4

var dungeon:Dungeon

func generate() -> void:
	dungeon = Dungeon.new()
	pass

		
static func generate_door(cell:Vector2i, side:Vector2i)->Door:
		var door:Door = Door.new()
		door.cell = cell
		door.side = side
		return door
		
static func generate_room_for_spec(room_size:Vector2i, position:Vector2i)->Room:
	var room:Room = Room.new()
	room.size=room_size
	room.cell=position
	return room
