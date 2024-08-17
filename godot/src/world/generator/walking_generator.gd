class_name WalkingGenerator extends DungeonGenerator



var test_spec=[ Vector2i(1,1),
	Vector2i(2,1),
	Vector2i(1,1),
	Vector2i(1,2),
	Vector2i(1,1),
	Vector2i(1,1),
	Vector2i(1,1),
	Vector2i(2,2),
	Vector2i(1,1),
	
]



func generate() -> void:
	var spec = test_spec.duplicate()
	dungeon= Dungeon.new()
	spec.shuffle()
		#first room, cell zero, bottom door is entry/exit
	var current_cell = Vector2i.ZERO
	var current_room:Room = generate_room_for_spec(spec.pop_front(), current_cell)
	var entry_door:Door = generate_door(Vector2i.ZERO, Vector2i.DOWN)
	current_room.doors.append(entry_door)
	var position_stack:Array[Vector2i] = [current_cell]
	var used_cells:Array=[]
	dungeon.rooms=[current_room]
	
	while not spec.is_empty():
		current_cell+=[Vector2i.UP,Vector2i.DOWN,Vector2i.LEFT,Vector2i.RIGHT]
		position_stack.push_front(current_cell)
		var new_room=dungeon.get_room_for_cell(current_cell)
		if new_room == current_room:
			continue
		if new_room != null:
			current_room.doors.append(generate_door(current_cell- current_room.cell, current_cell-position_stack[1]))
			
			
		#var room_spec = spec.pick_random()
		#var room:Room = generate_room_for_spec(room_spec, current_cell)
		#position_stack.push_front(current_cell)
		#rooms.append(room)
