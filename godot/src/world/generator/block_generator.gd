class_name BlockGenerator extends DungeonGenerator

@export var size:Vector2i = Vector2i(4,4)
@export var max_attempts := 50
@export var min_coverage := .5
@export var max_coverage := .6
@export var s1x1_count := 4
@export var s2x1_count := 2
@export var s1x2_count := 2
@export var s2x2_count := 1
@export var block_limit := false
@export var cycle_factor := .1
var matrix=[]

	
func generate() -> void:
	Logger.info("***************************")
	Logger.info("Generating dungeon size %s" % size)
	
	var valid_room_sizes = []
	
	for i in range(s1x1_count):
		valid_room_sizes.append(Vector2i(1,1))
	for i in range(s1x2_count):
		valid_room_sizes.append(Vector2i(1,2))
	for i in range(s2x1_count):
		valid_room_sizes.append(Vector2i(2,1))
	for i in range(s2x2_count):
		valid_room_sizes.append(Vector2i(2,2))
		
	dungeon = Dungeon.new()
	init_matrix()

	Logger.info("Generating rooms")
	while not valid_room_sizes.is_empty():
		var room_size:Vector2i = Vector2i.ONE if dungeon.rooms.is_empty() else valid_room_sizes.pick_random()
		var room_position:RoomCell = get_room_position(room_size)
		if room_position == null:
			while valid_room_sizes.has(room_size):
				valid_room_sizes.erase(room_size)
			continue
		var room = generate_room_for_spec(room_size, room_position.cell)
		place_room(room)
		if block_limit:
			valid_room_sizes.erase(room_size)
	
	Logger.info("Generated %d rooms" % dungeon.rooms.size())
	
	print()
	
	prune()
	
	print()
	Logger.info("Final dungeon has %d rooms" % dungeon.rooms.size())
	
	create_doors()
	
	for room in dungeon.rooms:
		Logger.info("%s" % room)
	
	
	Logger.info("***************************")
func create_doors():
	var room_positions:=[]
	for room in dungeon.rooms:
		room_positions.append(room.cell)
	
	
	for c in get_mst():
		var ro:Room = dungeon.rooms[c.x]
		var rd:Room = dungeon.rooms[c.y]
		var door :Door = get_door_options(ro,rd).pick_random()
		ro.doors.append(door)
		var reverse_door:Door = Door.new()
		reverse_door.side = door.side * -1
		# dest room abs cell -(ori room cell
		reverse_door.cell = rd.cell - ((ro.cell+door.cell)-door.side)
		rd.doors.append(reverse_door)
		
	#for p in mst.get_points():
		#var ro = dungeon.get_room_for_cell(p)
		#assert(ro)
		#for c in mst.get_point_connections(p):
			#var rd = dungeon.get_room_for_cell(mst.get_point_position(c))
			#assert(rd)
			
	
	
func remove_room(room:Room):
	dungeon.rooms.erase(room)
	for x in range(room.size.x):
		for y in range(room.size.y):
			matrix[room.cell.x+x][room.cell.y+y]=null

func place_room(room:Room):
	for cell in room.get_cells():
		matrix[cell.x][cell.y]=room
	dungeon.rooms.append(room)
	
func prune()->void:
	Logger.info("Prunning")
	var last_room_removed:Room
	#remove rooms until we are under max coverage
	var attempt:int =0
	while get_coverage()> max_coverage and attempt < max_attempts:
		last_room_removed = dungeon.rooms.pick_random()
		if last_room_removed == dungeon.rooms[0]:
			attempt+=1
			continue
		remove_room(last_room_removed)
		if not are_all_rooms_wall_connected():
			place_room(last_room_removed)
			attempt+=1
			continue
		
		Logger.info("Removed room %s" % last_room_removed)
		
	#if we went under min coverage, then replace last removed room (even if we go above max coverage)
	if get_coverage()<min_coverage and last_room_removed != null:
		place_room(last_room_removed)
		Logger.info("Replaced room %s" % last_room_removed)
		
	Logger.info("Coverage %2f" % get_coverage())
	
func init_matrix():
	matrix = []
	for x in range(size.x):
		var column=[]
		for y in range(size.y):
			column.append(null)
		matrix.append(column)
		
			
#func is_room_wall_connected(room:Room)->bool:
	#var adjcent_cells:=[]
	#for cell in room.get_cells():
		#var neighbors = get_adjacent_cells(cell)
		#for neighbor in neighbors:
			#if not neighbor in room.get_cells() and not neighbor in adjcent_cells:
				#adjcent_cells.append(neighbor)
	#for neighbor in adjcent_cells:
		#if matrix[neighbor.x][neighbor.y]!=null:
			#return true
	#return false

func get_coverage()->float:
	var cells_used:float = 0
	for room in dungeon.rooms:
		cells_used += room.size.x * room.size.y
		
	return cells_used/ float(size.x * size.y)
	
func are_all_rooms_wall_connected()->bool:
	var checked_rooms=[]
	var rooms_to_check=[dungeon.rooms[0]]
	while not rooms_to_check.is_empty():
		var current_room=rooms_to_check.pop_front()
		checked_rooms.append(current_room)
		var new_rooms = get_wall_connected_rooms(current_room)
		for nr in new_rooms:
			if not nr in checked_rooms and not nr in rooms_to_check:
				rooms_to_check.append(nr)
		
	return checked_rooms.size() == dungeon.rooms.size()
	
func get_door_options(room1:Room, room2:Room)->Array:
	var ret=[]
	var room1_cells=get_cells_adjacent_to_neighbor(room1, room2)
	var room2_cells=get_cells_adjacent_to_neighbor(room2, room1)
	for c1 in room1_cells:
		for c2 in room2_cells:
			for dir in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
				if c1 - dir == c2:
					var door:Door = Door.new()
					door.cell=c1
					door.side=dir
					ret.append(door)
	return ret
	
func get_cells_adjacent_to_neighbor(room:Room, neighbor:Room)->Array:
	var ret=[]
	for cell in room.get_cells():
		var cells = get_adjacent_cells(cell).filter(func(c): return c in neighbor.get_cells())
		for nc in cells:
			if not nc in ret:
				ret.append(nc)
	return ret
func get_wall_connected_rooms(room:Room)->Array:
	var neighbor_rooms=[]
	var adjcent_cells:=[]
	for cell in room.get_cells():
		var neighbors = get_adjacent_cells(cell)
		for neighbor in neighbors:
			if not neighbor in room.get_cells() and not neighbor in adjcent_cells:
				adjcent_cells.append(neighbor)
	for neighbor in adjcent_cells:
		if matrix[neighbor.x][neighbor.y]!=null:
			if not matrix[neighbor.x][neighbor.y] in neighbor_rooms:
				neighbor_rooms.append(matrix[neighbor.x][neighbor.y])
	return neighbor_rooms
	
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
	for delta in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
			var neighbor:Vector2i = cell + delta
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

func print():

	for y in range(size.y):
		var row=" ."
		for x in range(size.x):
			if matrix[x][y]==null:
				row+=" "
			else:
				row+= "%2d." % dungeon.rooms.find(matrix[x][y])
		Logger.info(row)

func segment_adds_loop(new_segment:Vector2i, astar:AStar2D)->bool:
	return not astar.get_id_path(new_segment.x, new_segment.y).is_empty
	
func get_mst()->Array[Vector2i]:
	var astar=AStar2D.new()
	for i in range(dungeon.rooms.size()):
		astar.add_point(i, dungeon.rooms[i].cell)

	var segments=[]
	for i in range(dungeon.rooms.size()):
		var room = dungeon.rooms[i]
		var neighbors = get_wall_connected_rooms(room)
		for n in neighbors:
			var nidx = dungeon.rooms.find(n)
			assert(nidx >=0)
			if not (Vector2i(i,nidx) in segments or Vector2i(nidx,i) in segments):
				segments.append(Vector2i(i,nidx))
	
	var available_segments=segments.duplicate()
	#var lengths:=[]
	#for s in segments:
		#lengths.append(points[s.x].distance_to(points[s.y]))
	#available_segments.sort_custom(func (a,b): return lengths[available_segments.find(b)]>lengths[available_segments.find(a)])

	var ret:Array[Vector2i]=[]

	for i in range(dungeon.rooms.size()-1):
		var new_segment=available_segments.pop_front()
		while segment_adds_loop(new_segment, astar):
			if available_segments.is_empty():
				Logger.error("Failed to find MST")
				assert(false)
				return []				
			new_segment=available_segments.pop_front()
		ret.append(new_segment)
		astar.connect_points(new_segment.x, new_segment.y)
		
	var extra_count:int = floor(available_segments.size()*cycle_factor)
	for i in range(extra_count):
		ret.append(available_segments.pop_front())
	return ret
#func find_mst(nodes):
	## Prim's algorithm
	## Given an array of positions (nodes), generates a minimum
	## spanning tree
	## Returns an AStar object
#
	## Initialize the AStar and add the first point
	#var path = AStar2D.new()
	#path.add_point(path.get_available_point_id(), nodes.pop_front())
#
	## Repeat until no more nodes remain
	#while nodes:
		#var min_dist = INF  # Minimum distance found so far
		#var min_p = null  # Position of that node
		#var p = null  # Current position
		## Loop through the points in the path
		#for p1 in path.get_points():
			#p1 = path.get_point_position(p1)
			## Loop through the remaining nodes in the given array
			#for p2 in nodes:
				## If the node is closer, make it the closest
				#if p1.distance_to(p2) < min_dist:
					#min_dist = p1.distance_to(p2)
					#min_p = p2
					#p = p1
		## Insert the resulting node into the path and add
		## its connection
		#var n = path.get_available_point_id()
		#path.add_point(n, min_p)
		#path.connect_points(path.get_closest_point(p), n)
		## Remove the node from the array so it isn't visited again
		#nodes.erase(min_p)
	#return path
	
	
class RoomCell:
	var cell:Vector2i
	func _init(new_cell:Vector2i) -> void:
		self.cell = new_cell
#func get_empty_cells() -> Array
