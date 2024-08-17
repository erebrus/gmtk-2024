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
	owner.anim_player.play("dash")	
	owner.sfx_dash.play()
	await tween.finished
	owner.in_animation=false
	dash_done = true
	
# This function is called each frame if the state is ACTIVE
# XSM updates the root first, then the children
func _on_update(_delta: float) -> void:
	if dash_done:
		change_state("idle")
