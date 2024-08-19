@tool
class_name WorldRoom extends Node2D

signal door_entered(door: WorldDoor)

	#Vector2i(1,1):[
		#Vector2i.ONE*Globals.TILES_PER_ROOM*Globals.TILE_SIZE/2.0
	#]
#}
const LANDMARK_SCENES = [
		preload("res://src/world/room/landmarks/fountain_landmark.tscn"),
		preload("res://src/world/room/landmarks/bones_landmark.tscn")		,
		preload("res://src/world/room/landmarks/pink_button_landmark.tscn"),
		preload("res://src/world/room/landmarks/green_button_landmark.tscn")		
		]
const HINT_SCENE = preload("res://src/world/room/hint/world_hint.tscn")
@export var cell: Vector2i
@export var size: Vector2i


@export_category("Scenes")

@export var DoorScene: PackedScene

@warning_ignore("confusable_identifier")
var floor: TileMapLayer
var walls: TileMapLayer
var tile_size: Vector2i
var doors: Array[WorldDoor]

var landmark:Node2D
var hint:Node2D
var trap:Node2D

var data:Room


var flip_h := TileSetAtlasSource.TRANSFORM_FLIP_H
var flip_v := TileSetAtlasSource.TRANSFORM_FLIP_V
var transpose := TileSetAtlasSource.TRANSFORM_TRANSPOSE
var tile_transforms := {
	Vector2i.UP : [0],
	Vector2i.RIGHT : [flip_h, transpose],
	Vector2i.DOWN : [flip_v, flip_h],
	Vector2i.LEFT : [flip_v, transpose],
	
}
func _ready() -> void:
	assert(DoorScene != null)
	

func build(room_data: Room) -> void:
	data = room_data
	walls = %Walls
	floor = $"%Floor"
	tile_size = walls.tile_set.tile_size
	cell = room_data.cell
	size = room_data.size
	
	_build_walls()
	_build_floor()
	if room_data.landmark:
		_build_landmark(room_data.landmark)
	#if room_data.trap:
		#_build_trap(room_data.trap)
	if room_data.hint:
		_build_hint(room_data.hint)
	for door_data in room_data.doors:
		_add_door(door_data.cell, door_data.side)
		
	
	

func get_door(door: Door) -> WorldDoor:
	for d in doors:
		if d.cell == door.cell and d.side == door.side:
			return d
	
	assert(false, "Could not find door  %s" % door)
	return null
	
func _build_floor() -> void:
	if not data.matrix:
		data.build_tiles()
		
	var room_size = Globals.TILES_PER_ROOM * size
	for x in room_size.x:
		for y in room_size.y:
			var tile_type:Vector2i 
			match data.matrix[x][y]:
				0:
					tile_type = Vector2(7,8)
				_:
					if data.matrix[x][y] is int and data.matrix[x][y]==1:
						data.matrix[x][y] = Vector2(randi_range(8,11),8)
					tile_type = data.matrix[x][y]
			floor.set_cell(Vector2i(x,y),0,tile_type)
	#
	#for door in data.doors:
		#var pos:=Vector2i.ZERO
		#var delta:=Vector2i.ZERO
		#match door.side:
			#Vector2i.UP:
				#pos.y = 0
				#pos.x = door.cell.x*Globals.TILES_PER_ROOM+ floor(Globals.TILES_PER_ROOM/2.0)
				#delta=Vector2i.RIGHT
			#Vector2i.DOWN:
				#pos.y=room_size.y-1
				#pos.x = door.cell.x*Globals.TILES_PER_ROOM+ floor(Globals.TILES_PER_ROOM/2.0)
				#delta=Vector2i.RIGHT
			#Vector2i.LEFT:
				#pos.x=0
				#pos.y = door.cell.y*Globals.TILES_PER_ROOM+ floor(Globals.TILES_PER_ROOM/2.0)
				#delta=Vector2i.DOWN
			#Vector2i.RIGHT:
				#pos.x=room_size.x-1
				#pos.y = door.cell.y*Globals.TILES_PER_ROOM+ floor(Globals.TILES_PER_ROOM/2.0)
				#delta=Vector2i.DOWN
				#
		#for i in range(4):
			#floor.set_cell(pos+door.side*i,0,Vector2(7,8))
			#floor.set_cell(pos+delta+door.side*i,0,Vector2(7,8))
	#
		
	
func _build_walls() -> void:
	Logger.info("Creating room of size %s" % size)
	
	var room_size = Globals.TILES_PER_ROOM * size
	
	for w in range(1,room_size.x-1):
		walls.set_cell(Vector2i(w,0),0,Vector2i(randi_range(9,15),11),get_applied_transform(Vector2.DOWN))
		walls.set_cell(Vector2i(w,room_size.y-1),0,Vector2i(randi_range(9,15),11),get_applied_transform(Vector2.UP))
	for h in range(1,room_size.y-1):
		walls.set_cell(Vector2i(0,h),0,Vector2i(randi_range(9,15),11),get_applied_transform(Vector2.RIGHT))
		walls.set_cell(Vector2i(room_size.x-1,h),0,Vector2i(randi_range(9,15),11),get_applied_transform(Vector2.LEFT))

	walls.set_cell(Vector2i(room_size.x-1, room_size.y-1),0,Vector2i(17,11),0)
	walls.set_cell(Vector2i(0, room_size.y-1),0,Vector2i(17,11),get_applied_transform(Vector2.RIGHT))
	walls.set_cell(Vector2i(room_size.x-1, 0),0,Vector2i(17,11),get_applied_transform(Vector2.LEFT))
	walls.set_cell(Vector2i(0, 0),0,Vector2i(17,11),get_applied_transform(Vector2.DOWN))
	
	for door in data.doors:
		var pos:=Vector2i.ZERO
		var delta:=Vector2i.ZERO
		var cell_transform:int
		var cell_transform2:int
		match door.side:
			Vector2i.UP:
				pos.y = 0
				pos.x = door.cell.x*Globals.TILES_PER_ROOM+ floor(Globals.TILES_PER_ROOM/2.0)
				delta=Vector2i.RIGHT
				cell_transform = get_applied_transform(door.side*-1)
				cell_transform2 = get_applied_transform(door.side*-1)-flip_h
			Vector2i.DOWN:
				pos.y=room_size.y-1
				pos.x = door.cell.x*Globals.TILES_PER_ROOM+ floor(Globals.TILES_PER_ROOM/2.0)
				delta=Vector2i.RIGHT
				cell_transform = get_applied_transform(door.side*-1)+flip_h
				cell_transform2 = get_applied_transform(door.side*-1)
			Vector2i.LEFT:
				pos.x=0
				pos.y = door.cell.y*Globals.TILES_PER_ROOM+ floor(Globals.TILES_PER_ROOM/2.0)
				delta=Vector2i.DOWN
				cell_transform = get_applied_transform(door.side*-1)+flip_v
				cell_transform2 = get_applied_transform(door.side*-1)
			Vector2i.RIGHT:
				pos.x=room_size.x-1
				pos.y = door.cell.y*Globals.TILES_PER_ROOM+ floor(Globals.TILES_PER_ROOM/2.0)
				delta=Vector2i.DOWN
				cell_transform = get_applied_transform(door.side*-1)
				cell_transform2 = get_applied_transform(door.side*-1)-flip_v
		walls.set_cell(pos,-1,)
		walls.set_cell(pos+delta,-1)
		walls.set_cell(pos-delta,0,Vector2i(8,11),cell_transform)
		walls.set_cell(pos+2*delta,0,Vector2i(8,11),cell_transform2)
		
		#walls.set_cell(pos-delta,-1)
	#walls.set_cells_terrain_connect(room_cells, 0, 0)

func get_applied_transform(direction:Vector2i):
	var ret :=0
	for i in tile_transforms[direction]:
		ret += i
	return ret
func get_room_pixel_size() -> Vector2:
	return size * Globals.TILE_SIZE * Globals.TILES_PER_ROOM


func _add_door(door_cell: Vector2i, side: Vector2i) -> void:
	var door = DoorScene.instantiate()
	door.room = self
	door.cell = door_cell
	door.side = side
	doors.append(door)
	
	door.door_entered.connect(_on_door_entered.bind(door))
	
	%Doors.add_child(door)


func _build_hint(hint_data:Hint):
	if hint_data.found:
		return
		
	hint = HINT_SCENE.instantiate()	
	hint.data = hint_data
	add_child(hint)
	if not hint_data.built:
		var pos:= (get_room_pixel_size()-Vector2.ONE*Globals.HINT_SIZE*2)*randf()+Vector2.ONE*Globals.HINT_SIZE 
		var attempt := 0
		while not is_hint_position_valid(pos):
			attempt +=1	
			pos = (get_room_pixel_size()-Vector2.ONE*Globals.HINT_SIZE*2)*randf()+Vector2.ONE*Globals.HINT_SIZE 
			if attempt > 100:
				Logger.error("Failed to add hint after 100 attempts. Setting middle of the room.")
				hint.position = get_room_pixel_size()/2.0
				return
		if attempt > 10:
			Logger.info("Added hint after %d" % attempt)			
		hint_data.position = pos
		hint_data.built = true
		
	hint.global_position = hint_data.position
					
func _build_landmark(landmark_data:Landmark):
	landmark = LANDMARK_SCENES[landmark_data.type].instantiate()
	landmark.data = landmark_data
	add_child(landmark)
	if not landmark_data.built:
		var pos:= (get_room_pixel_size()-Vector2.ONE*Globals.LANDMARK_SIZE*2)*randf()+Vector2.ONE*Globals.LANDMARK_SIZE 
		var attempt := 0
		while not is_landmark_position_valid(pos):
			attempt += 1
			pos = (get_room_pixel_size()-Vector2.ONE*Globals.LANDMARK_SIZE*2)*randf()+Vector2.ONE*Globals.LANDMARK_SIZE 		
			if attempt > 100:
				Logger.error("Failed to add landmark after 100 attempts. Setting middle of the room.")
				landmark.position = get_room_pixel_size()/2.0
				return
		if attempt > 10:
			Logger.info("Added landmark after %d" % attempt)
		landmark_data.position = pos
		landmark_data.built = true
	landmark.update_state()
	landmark.global_position = landmark_data.position
		
func is_hint_position_valid(pos:Vector2)-> bool:
	if pos.x < Globals.HINT_SIZE  or pos.y < Globals.HINT_SIZE:
		return false
	
	if pos.x > get_room_pixel_size().x - Globals.HINT_SIZE  or pos.y > get_room_pixel_size().y - Globals.HINT_SIZE:
		return false

	if landmark and landmark.global_position.distance_to(pos)< Globals.LANDMARK_SIZE * 2:
		return false
	return true

func is_landmark_position_valid(pos:Vector2)-> bool:
	if pos.x < Globals.LANDMARK_SIZE  or pos.y < Globals.LANDMARK_SIZE:
		return false
	
	if pos.x > get_room_pixel_size().x - Globals.LANDMARK_SIZE  or pos.y > get_room_pixel_size().y - Globals.LANDMARK_SIZE:
		return false
	
	for d in doors:
		if d.global_position.distance_to(pos) < Globals.LANDMARK_SIZE*2:
			return false
	return true


func _on_door_entered(door: WorldDoor) -> void:
	Logger.info("entered door")
	door_entered.emit(door)
	

func _to_string() -> String:
	return "%sx%s room at %s. %s Doors." % [
		size.x,
		size.y,
		cell,
		doors.size()
	]
