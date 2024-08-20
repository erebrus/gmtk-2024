class_name BlockGenerator extends Resource

@export var size:Vector2i = Vector2i(4,4)
@export var hint_ratio := .2
@export var trap_ratio := .1
@export var landmark_ratio := .4
@export var time := 30.0

@export var max_attempts := 50
@export var min_coverage := .5
@export var max_coverage := .6
@export var s1x1_count := 4
@export var s2x1_count := 2
@export var s1x2_count := 2
@export var s2x2_count := 1
@export var block_limit := false
@export var cycle_factor := .1

var dungeon:Dungeon
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
	dungeon.size = size
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
	
	prune()
	
	Logger.info("Final dungeon has %d rooms" % dungeon.rooms.size())
	Logger.info("Create doors")	
	create_doors()

	Logger.info("Generating hints")
	for i in range(round(dungeon.rooms.size()*hint_ratio)):
		var room:Room = dungeon.rooms.pick_random()
		while room.hint:
			room = dungeon.rooms.pick_random()
		room.hint = Hint.new()
			
	Logger.info("Generating landmarks")
	for i in range(round(dungeon.rooms.size()*landmark_ratio)):
		var room:Room = dungeon.rooms.pick_random()
		while room.landmark or room.trap:
			room = dungeon.rooms.pick_random()
		
		room.landmark = Landmark.new()
		room.landmark.type = randi() % Types.Landmarks.size()
	
	Logger.info("Generating traps")
	for i in range(round(dungeon.rooms.size()*trap_ratio)):
		var room:Room = dungeon.rooms.pick_random()
		while room.landmark or room.trap:
			room = dungeon.rooms.pick_random()
		room.trap = randi_range(1,Types.Traps.size())
	
	for room in dungeon.rooms:
		Logger.info("%s" % room)
	
	if not are_all_rooms_door_connected():
		Logger.error("Missing connections!!")
	Logger.info("***************************")
	#dungeon.rooms[0].print_content()

func create_doors():
	
	var room_positions:=[]
	for room in dungeon.rooms:
		room_positions.append(room.cell)
	
	var mst = get_mst()
	for c in mst:
		var ro:Room = dungeon.rooms[c.x]
		var rd:Room = dungeon.rooms[c.y]
		var door :Door = get_door_options(ro,rd).pick_random()
		ro.doors.append(door)
		var reverse_door:Door = Door.new()
		reverse_door.side = door.side * -1
		# dest room abs cell -(ori room cell
		reverse_door.cell = ((ro.cell+door.cell)+door.side) - rd.cell
		rd.doors.append(reverse_door)
	
	var start_door:Door = Door.new()
	start_door.cell=Vector2i.ZERO
	start_door.side=Vector2i.DOWN
	start_door.exit=true
	dungeon.rooms[0].doors.push_front(start_door)
	
	_set_other_exit_door()
	
	
func _set_other_exit_door():
	var options := []
	for room in dungeon.rooms:
		options.append_array(room.get_possible_exit_doors())
	var best_dist=0
	var best:Door
	for door in options:
		var room = dungeon.get_room_for_cell(door.cell)
		if room==dungeon.start_room:
			continue
		var dist = dungeon.start_room.cell.distance_to(door.cell)
		if best==null or dist > best_dist:
			best_dist = dist
			best = door
	var room:Room = dungeon.get_room_for_cell(best.cell)
	best.cell -= room.cell
	room.doors.append(best)
	
		
	
	
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
		

func get_coverage()->float:
	var cells_used:float = 0
	for room in dungeon.rooms:
		cells_used += room.size.x * room.size.y
		
	return cells_used/ float(size.x * size.y)
	

func get_door_connected_rooms(room:Room)->Array:
	var ret:=[]
	for door in room.doors:
		if door.exit:
			continue
		var other_pos := room.cell+door.cell+door.side
		var other = dungeon.get_room_for_cell(other_pos)
		assert(other)
		ret.append(other)
		
	return ret


func are_all_rooms_door_connected()->bool:
	var checked_rooms=[]
	var rooms_to_check=[dungeon.rooms[0]]
	while not rooms_to_check.is_empty():
		var current_room=rooms_to_check.pop_front()
		checked_rooms.append(current_room)
		var new_rooms = get_door_connected_rooms(current_room)
		for nr in new_rooms:
			if nr and not nr in checked_rooms and not nr in rooms_to_check:
				rooms_to_check.append(nr)
		
	return checked_rooms.size() == dungeon.rooms.size()	
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
	var room2_cells=get_adjacent_neighbor_cells(room1, room2)
	var room1_cells=get_adjacent_neighbor_cells(room2, room1)
	for c1 in room1_cells:
		for c2 in room2_cells:
			for dir in [Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]:
				if c1 + dir == c2:
					var door:Door = Door.new()
					door.cell=c1 - room1.cell
					door.side=dir
					ret.append(door)
	return ret
	
func get_adjacent_neighbor_cells(room:Room, neighbor:Room)->Array:
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
		
	var possible_positions = get_possible_cell_positions(room_size)
	while not possible_positions.is_empty():
		var cell:Vector2i = possible_positions.pick_random()
		possible_positions.erase(cell)
		if does_room_fit(room_size,cell):
			return RoomCell.new(cell)
	return null
	
func does_room_fit(room_size:Vector2i, cell:Vector2i)-> bool:
	for x in range(room_size.x):
		for y in range(room_size.y):
			var new_cell:=cell+Vector2i(x,y)
			if not is_cell_in_dungeon(new_cell) or matrix[new_cell.x][new_cell.y] != null:
				return false
	return true
	
func is_cell_in_dungeon(cell:Vector2i):
	return not(cell.x < 0 or cell.x >= size.x or cell.y < 0 or cell.y >= size.y)
	
func get_possible_cell_positions(room_size:Vector2i)-> Array:
	var ret := []
	for x in range(size.x):
		for y in range(size.y):
			var adjacent:=false
			var valid:=true
			for rx in range(room_size.x):
				for ry in range(room_size.y):
					if not is_cell_in_dungeon(Vector2i(x+rx,y+ry)) or matrix[x+rx][y+ry] != null:
						valid=false
						break
					if is_next_to_room(Vector2i(x+rx,y+ry)):
						adjacent=true
			if valid and adjacent:
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
	return not astar.get_id_path(new_segment.x, new_segment.y).is_empty()
	
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

	
class RoomCell:
	var cell:Vector2i
	func _init(new_cell:Vector2i) -> void:
		self.cell = new_cell
