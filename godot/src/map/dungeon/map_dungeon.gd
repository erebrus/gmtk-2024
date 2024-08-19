class_name MapDungeon extends Node2D

const GRID_SIZE = Vector2i(10, 10)


@export_category("Scenes")
@export var RoomScene: PackedScene

var dungeon: Dungeon
var grid_cell_offset: Vector2i
var grid_offset: Vector2
var rooms: Array[MapRoom]


func _ready() -> void:
	assert(RoomScene != null)
	
	dungeon = Globals.dungeon
	grid_cell_offset = (GRID_SIZE - dungeon.size) / 2
	grid_offset = global_position + Vector2(grid_cell_offset) * Globals.MAP_CELL_SIZE
	_add_start_room()
	

func add_room(room: MapRoom) -> void:
	room.visible = false
	rooms.append(room)
	room.dungeon = self
	room.dropped.connect(_on_room_dropped.bind(room))
	add_child(room)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(room):
		room.visible = true
	

func add_landmark(landmark: MapLandmark) -> void:
	landmark.visible = false
	landmark.dungeon = self
	landmark.dropped.connect(_on_landmark_dropped.bind(landmark))
	add_child(landmark)
	
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(landmark):
		landmark.visible = true
	

func cell_from_global_position(global: Vector2) -> Vector2i:
	if global.x < grid_offset.x:
		global.x -= Globals.MAP_CELL_SIZE
	if global.y < grid_offset.y:
		global.y -= Globals.MAP_CELL_SIZE
	
	var grid_position: Vector2i = global - grid_offset
	return grid_position / Globals.MAP_CELL_SIZE
	

func cell_to_global_position(cell: Vector2i) -> Vector2:
	return grid_offset + Vector2(cell) * Globals.MAP_CELL_SIZE
	

func evaluate() -> MapScore:
	var score = MapScore.new()
	for x in dungeon.size.x:
		for y in dungeon.size.y:
			var cell = Vector2i(x, y)
			var drawn_room = find_room(cell)
			var target_room = dungeon.get_room_for_cell(cell)
			Logger.debug("CELL %s" % cell)
			if target_room != null:
				if drawn_room != null:
					score.check_room_exists(true)
					drawn_room.evaluate(target_room, score)
				else:
					score.check_room_exists(false)
			else:
				pass
				# TODO: penalize somehow for extra rooms?
			
	score.calculate_totals()
	return score
	

func find_room(cell: Vector2i) -> MapRoom:
	for room in rooms:
		if room.any_cell(func(c): return c == cell):
			return room
	return null
	

func _add_start_room() -> void:
	var start_room = dungeon.rooms.front()
	var room: MapRoom = RoomScene.instantiate()
	room.size = start_room.size
	room.cell = start_room.cell
	room.is_start_room = true
	add_room(room)
	room._move_to_cell()
	
	var start_door = start_room.doors.front()
	room.activate_door(start_door.cell, start_door.side, true)
	

func _is_cell_outside_grid(cell: Vector2i) -> bool:
	var grid_cell = cell + grid_cell_offset
	return  grid_cell.x < 0 or grid_cell.x >= GRID_SIZE.x or grid_cell.y < 0 or grid_cell.y >= GRID_SIZE.y
	

func _on_room_dropped(room: MapRoom) -> void:
	if _is_cell_outside_grid(room.cell):
		Logger.info("Deleting room dropped outside of grid %s" % room.cell)
		rooms.erase(room)
		room.queue_free()
	

func _on_landmark_dropped(landmark: MapLandmark) -> void:
	if landmark.room != null and is_instance_valid(landmark.room):
		landmark.room.remove_landmark(landmark)
	
	if _is_cell_outside_grid(landmark.cell):
		_delete_landmark(landmark)
		return
		
	var room = find_room(landmark.cell)
	if room == null:
		_delete_landmark(landmark)
		return
	
	room.add_landmark(landmark)
	landmark.reparent(room)
	

func _delete_landmark(landmark: MapLandmark) -> void:
	Logger.info("Deleting landmark dropped outside of room %s" % landmark.cell)
	landmark.queue_free()
