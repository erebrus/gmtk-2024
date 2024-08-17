class_name BlockGenerator extends DungeonGenerator

@export var size:Vector2i = Vector2i(8,8)
@export var max_attempts := 100

var matrix=[]
var room_sizes:Array[Vector2i]=[
	Vector2i(1,1),
	Vector2i(2,1),
	Vector2i(1,2),
	Vector2i(2,2)
	]
	
func generate() -> void:
	var valid_room_sizes = room_sizes.duplicate()
	dungeon = Dungeon.new()
	init_matrix()

	while not valid_room_sizes.is_empty():
		var room_size:Vector2i = valid_room_sizes.pick_random()
		var room_position:RoomCell = get_room_position(room_size)
		if room_position == null:
			valid_room_sizes.erase(room_size)
			continue
		var room = generate_room_for_spec(room_size, room_position.cell)
		for cell in room.get_cells():
			matrix[cell.x][cell.y]=room
		
	
func init_matrix():
	matrix = []
	for x in range(size.x):
		var column=[]
		for y in range(size.y):
			column.append(null)
		matrix.append(column)
		
			
	
func get_room_position(size:Vector2i)->RoomCell:
	if dungeon.rooms.is_empty():
		return RoomCell.new(Vector2i.ZERO)
	var possible_positions = get_possible_cell_positions()
	while not possible_positions.is_empty():
		var cell:Vector2i = possible_positions.pick_random()
		possible_positions.erase(cell)
		if does_room_fit(size,cell):
			return RoomCell.new(cell)
	return null
	
func does_room_fit(size:Vector2i, cell:Vector2i)-> bool:
	for x in range(size.x):
		for y in range(size.y):
			var new_cell:=cell+Vector2i(x,y)
			if matrix[new_cell.x][new_cell.y] != null:
				return false
	return true
	
func get_possible_cell_positions()-> Array:
	var ret := []
	for x in range(size.x):
		for y in range(size.y):
			if matrix[x][y] == null and is_next_to_room(Vector2i(x,y)):
				ret.append(Vector2i(x,y))
	return ret
		
func is_next_to_room(cell:Vector2i) -> bool:	
	var neighbors = get_adjacent_cells(cell)
	for neighbor in neighbors:
		if matrix[neighbor.x][neighbor.y] !=null:
			return true
	return false

func get_adjacent_cells(cell:Vector2i) -> Array:
	var ret := []
	for x in range(-1,1):
		for y in range(-1,1):
			if x==0 and y==0:
				continue
			var neighbor := cell + Vector2i (x,y)
			if neighbor.x < 0 or neighbor.x >= size.x or neighbor.y < 0 or neighbor.y >= size.y:
					continue
			ret.append(neighbor)
	return ret
	
func get_used_cells() -> Array:
	var ret:Array=[]
	for room in dungeon.rooms:
		for x in room.size.x:
			for y in room.size.y:
				ret.append(Vector2i(x,y))
	return ret

class RoomCell:
	var cell:Vector2i
	func _init(new_cell:Vector2i) -> void:
		self.cell = new_cell
#func get_empty_cells() -> Array
