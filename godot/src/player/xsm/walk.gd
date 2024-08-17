extends State


# This function is called when the state enters
# XSM enters the root first, the the children
func _on_enter(_args) -> void:
	#if owner.last_direction != Vector2.ZERO:
		#owner.anim_tree.set("parameters/walk/blend_position", owner.velocity.normalized())
		#owner.anim_tree.get("parameters/playback").travel("walk")
	#owner.sprite.flip_h=owner.last_direction.x<0
	pass




# This function is called each frame if the state is ACTIVE
# XSM updates the root first, then the children
func _on_update(_delta: float) -> void:	
	var direction:=Input.get_vector("move_left","move_right", "move_up", "move_down")
	var speed:float = owner.walk_speed
	if Input.is_action_pressed("sprint"):
		speed = owner.run_speed
		
	owner.velocity = direction * speed
	#owner.anim_tree.set("parameters/walk/blend_position", owner.velocity.normalized())
	if direction != Vector2.ZERO:
		if direction != Vector2.ZERO and direction!=owner.last_direction:
			owner.last_direction = direction
	else:
		change_state("idle")
