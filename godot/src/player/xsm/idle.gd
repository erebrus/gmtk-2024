extends State



# This function is called when the state enters
# XSM enters the root first, the the children
func _on_enter(_args) -> void:
	owner.anim_player.play("idle")
	
	#owner.anim_tree.set("parameters/idle/blend_position", owner.last_direction)
	#owner.anim_tree.get("parameters/playback").travel("idle")	
	#owner.sprite.flip_h=owner.last_direction.x<0




# This function is called each frame if the state is ACTIVE
# XSM updates the root first, then the children
func _on_update(_delta: float) -> void:
	var direction:=Input.get_vector("move_left","move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		if direction != Vector2.ZERO and direction!=owner.last_direction:
			owner.last_direction = direction
		change_state("walk")
	
