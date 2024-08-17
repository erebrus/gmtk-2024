extends State



var dash_done := false
#
# FUNCTIONS TO INHERIT IN YOUR STATES
#

# This function is called when the state enters
# XSM enters the root first, the the children
func _on_enter(_args) -> void:
	dash_done = false
	var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	owner.in_animation=true
	Logger.debug("last direction used in dash %s " % owner.last_direction)
	owner.velocity = owner.last_direction * owner.dash_impulse
	tween.tween_property(owner, "velocity", Vector2.ZERO, .5)
	if owner.last_direction.x==0 or owner.last_direction.y==0:
		owner.anim_player.play("dash")	
	else:
		owner.anim_player.play("dash_diag")	
	_update_sprite()
	owner.sfx_dash.play()
	await tween.finished
	owner.in_animation=false
	dash_done = true
	
# This function is called each frame if the state is ACTIVE
# XSM updates the root first, then the children
func _on_update(_delta: float) -> void:
	if dash_done:
		change_state("idle")


func _update_sprite():

	if owner.last_direction.x==0 or owner.last_direction.y==0:
		if owner.last_direction.y < 0:
			owner.sprite.rotation=0
		elif owner.last_direction.y > 0:
			owner.sprite.rotation=PI
		elif owner.last_direction.x < 0:
			owner.sprite.rotation=-PI/2
		elif owner.last_direction.x > 0:
			owner.sprite.rotation=PI/2
	else:
		owner.sprite.rotation=0
		if owner.last_direction.x < -.5 and owner.last_direction.y < -.5:
			owner.sprite.flip_h=false
			owner.sprite.flip_v=false
		elif owner.last_direction.x > .5 and owner.last_direction.y > .5:
			owner.sprite.flip_h=true
			owner.sprite.flip_v=true
		elif owner.last_direction.x < -.5 and owner.last_direction.y > .5:
			owner.sprite.flip_h=false
			owner.sprite.flip_v=true
		elif owner.last_direction.x > .5 and owner.last_direction.y < -.5:
			owner.sprite.flip_h=true
			owner.sprite.flip_v=false
