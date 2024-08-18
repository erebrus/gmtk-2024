extends State


# This function is called when the state enters
# XSM enters the root first, the the children
func _on_enter(_args) -> void:
	owner.anim_player.play("walk")
	_update_sprite()




# This function is called each frame if the state is ACTIVE
# XSM updates the root first, then the children
func _on_update(_delta: float) -> void:	
	if owner.in_animation:
		return 
	var direction:=Input.get_vector("move_left","move_right", "move_up", "move_down")
	var speed:float = owner.walk_speed
	if Input.is_action_pressed("sprint"):
		speed = owner.run_speed
		owner.anim_player.speed_scale=1
	else:
		owner.anim_player.speed_scale=.5
		
		
	owner.velocity = direction * speed
	if direction != Vector2.ZERO:
		if direction != Vector2.ZERO and direction!=owner.last_direction:
			Logger.info("new direction %s" % [direction])
			owner.last_direction = direction
			_update_sprite()
	else:
		change_state("idle")
	if not owner.can_move():
		change_state("idle")


func _update_sprite():

	if owner.last_direction.x==0 or owner.last_direction.y==0:
		owner.anim_player.current_animation="walk"
	else:
		owner.anim_player.current_animation="walk_diag"
	owner.update_sprite()
