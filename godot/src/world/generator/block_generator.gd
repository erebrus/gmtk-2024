class_name BlockGenerator extends DungeonGenerator

@export var size:Vector2i = Vector2i(4,4)
@export var max_attempts := 100
@export var min_coverage := .6
@export var max_coverage := .8

var matrix=[]
var room_sizes:Array[Vector2i]=[
	Vector2i(1,1),
	Vector2i(1,1),
	Vector2i(1,1),
	Vector2i(1,1),
	Vector2i(2,1),
	Vector2i(2,1),
	Vector2i(1,2),
	Vector2i(1,2),
	Vector2i(2,2)
	]
	
func generate() -> void:
	Logger.info("***************************")
	Logger.info("Generating dungeon size %s" % size)
	var valid_room_sizes = room_sizes.duplicate()
	dungeon = Dungeon.new()
	init_matrix()

	Logger.info("Generating rooms")
	while not valid_room_sizes.is_empty():
		var room_size:Vector2i = valid_room_sizes.pick_random()
		var room_position:RoomCell = get_room_position(room_size)
		if room_position == null:
			while valid_room_sizes.has(room_size):
				valid_room_sizes.erase(room_size)
			continue
		var room = generate_room_for_spec(room_size, room_position.cell)
		for cell in room.get_cells():
			matrix[cell.x][cell.y]=room
		dungeon.rooms.append(room)
	
	Logger.info("Generated %d rooms" % dungeon.rooms.size())
	
	prune()
	Logger.info("Final dungeon has %d rooms" % dungeon.rooms.size())
	Logger.info("***************************")
	
func prune()->void:
	Logger.info("Prunning")
	var last_room_removed:Room
	#remove rooms until we are under max coverage
	while get_coverage()> max_coverage:
		last_room_removed = dungeon.rooms.pick_random()
		dungeon.rooms.erase(last_room_removed)
		Logger.info("Removed room %s" % last_room_removed)
		
	#if we went under min coverage, then replace last removed room (even if we go above max coverage)
	if get_coverage()<min_coverage and last_room_removed != null:
		dungeon.rooms.append(last_room_removed)
		Logger.info("Replaced room %s" % last_room_removed)
		
	Logger.info("Coverage %2f" % get_coverage())
	
func init_matrix():
	matrix = []
	for x in range(size.x):
		var column=[]
		for y in range(size.y):
			column.append(null)
		matrix.append(column)
		
			
func is_room_wall_connected(room:Room)->bool:
	var adjcent_cells:=[]
	for cell in room.get_cells():
		var neighbors = get_adjacent_cells(cell)
		for neighbor in neighbors:
			if not neighbor in room.get_cells() and not neighbor in adjcent_cells:
				adjcent_cells.append(neighbor)
	for neighbor in adjcent_cells:
		if matrix[neighbor.x][neighbor.y]!=null:
			return true
	return false

func get_coverage()->float:
	var cells_used:float = 0
	for room in dungeon.rooms:
		cells_used += room.size.x * room.size.y
		
	return cells_used/ float(size.x * size.y)
	
func are_all_rooms_wall_connected()->bool:
	for room in dungeon.rooms:
		if not is_room_wall_connected(room):
			return false
	return true
		
func get_room_position(room_size:Vector2i)->RoomCell:
	if dungeon.rooms.is_empty():		
		return RoomCell.new(Vector2i(randi_range(0,size.x-room_size.x), size.y-room_size.y))
		
	var possible_positions = get_possible_cell_positions()
	while not possible_positions.is_empty():
		var cell:Vector2i = possible_positions.pick_random()
		possible_positions.erase(cell)
		if does_room_fit(room_size,cell):
			return RoomCell.new(cell)
	return null
	
func does_room_fit(size:Vector2i, cell:Vector2i)-> bool:
	for x in range(size.x):
		for y in range(size.y):
			var new_cell:=cell+Vector2i(x,y)
			if not is_cell_in_dungeon(new_cell) or matrix[new_cell.x][new_cell.y] != null:
				return false
	return true
	
func is_cell_in_dungeon(cell:Vector2i):
	return not(cell.x < 0 or cell.x >= size.x or cell.y < 0 or cell.y >= size.y)
	
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
	for x in range(-1,2):
		for y in range(-1,2):
			var neighbor := cell + Vector2i (x,y)
			if neighbor != cell and is_cell_in_dungeon(neighbor):				
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
