class_name Room extends Resource

@export var cell: Vector2i = Vector2i.ZERO
@export var size: Vector2i = Vector2i(1,1)

@export var doors: Array[Door]

@export var trap:Types.Traps
@export var landmark:Landmark
@export var hint:Hint

var doors_by_cell: Dictionary
var explored:=false
var matrix

func _to_string() -> String:
	return "%sx%s room at %s (%s,%s,%s). Doors:%s " % [
		size.x,
		size.y,
		cell,
		trap, landmark, hint != null,
		doors
	]


func build() -> bool:
	doors_by_cell.clear()
	
	for door in doors:
		if not _is_valid_door(door.cell, door.side):
			Logger.error("Door not valid position in room at room %s, cell %s, direction %s" % [cell, door.cell, door.side])
			return false
		
		if not doors_by_cell.has(door.cell):
			doors_by_cell[door.cell] = {}
		
		if doors_by_cell[door.cell].has(door.side):
			Logger.error("Room at %s has two doors at cell %s, direction %s" % [cell, door.cell, door.side])
			return false
		
		doors_by_cell[door.cell][door.side] = door
	
	return true
func print_content():
	build_tiles()
	var tile_size:Vector2i=size*Globals.TILES_PER_ROOM
	for y in range(tile_size.y):
		var row=""
		for x in range(tile_size.x):
			row += " " if matrix[x][y]==0 else "X"
		Logger.info(row)
			
func build_tiles():
	var start=Time.get_ticks_msec()
	matrix = []
	var tile_size:Vector2i=size*Globals.TILES_PER_ROOM
	for x in range(tile_size.x):
		var column = []
		for y in range(tile_size.y):
			column.append(0)
		matrix.append(column)
	
	for x in range(tile_size.x):
		for y in range(tile_size.y):
			var rng = randf()
			#for ri in range(Globals.TILE_RATIO.size()):
			if rng < Globals.FOLLIAGE_RATIO:
					matrix[x][y]=1
					
	for i in range(Globals.AUTOMATA_ITERS):
		var cell:Vector2i = Vector2i.ONE +Vector2i(randi()%tile_size.x-2, randi()%tile_size.y-2)
		if count_neighbor_tiles(cell, 0) > 4:
			matrix[cell.x][cell.y] = 0
		elif count_neighbor_tiles(cell, 0) < 4:
			matrix[cell.x][cell.y] = 1
	Logger.info("Room content in %ds" % (Time.get_ticks_msec()-start))
			
func count_neighbor_tiles(cell:Vector2i, type:int)->int:
	var count:=0
	for dx in range(-1,2):
		for dy in range(-1,2):
			if dx==0 and dy==0:
				continue
			if matrix[cell.x+dx][cell.y+dy] == type:
				count += 1
	return count

func get_cells()->Array:
	var ret := []
	for x in range(size.x):
		for y in range(size.y):
			ret.append(cell+Vector2i(x,y))
	return ret
	

func door_at(global_cell: Vector2i, side: Vector2i) -> Door:
	var local_cell = global_cell - cell
	var door = _find_door(local_cell, side)
	assert(door != null, "Could not find door at %s facing %s" % [global_cell, side])
	return door
	

func has_door(local_cell: Vector2i, side: Vector2i) -> bool:
	return _find_door(local_cell, side) != null
	

func _find_door(local_cell: Vector2i, side: Vector2i) -> Door:
	if doors_by_cell.has(local_cell) and doors_by_cell[local_cell].has(side):
		return doors_by_cell[local_cell][side]
	return null
	

func _is_valid_door(door_cell: Vector2i, door_side: Vector2i):
	if door_cell.x < 0 or door_cell.x >= size.x or door_cell.y < 0 or door_cell.y >= size.y:
		return false
	
	match door_side:
		Vector2i.UP:
			return door_cell.y == 0
		Vector2i.DOWN:
			return door_cell.y == size.y - 1
		Vector2i.LEFT:
			return door_cell.x == 0
		Vector2i.RIGHT:
			return door_cell.x == size.x - 1
	
	return false

func reset():
	explored=false
	if hint:
		hint.found = false
	if landmark:
		landmark.found = false
