extends CharacterBody2D

@export var dash_impulse:float = 400
@export var walk_speed:float = 30
@export var run_speed:float = 50
#@export var max_hp:float = 150

@onready var xsm = $xsm
@onready var anim_tree:AnimationTree = $AnimationTree
@onready var anim_player:AnimationPlayer = $AnimationPlayer

var last_direction:Vector2 = Vector2.DOWN
var in_animation:bool = false
#@onready var hp:float = max_hp


func _control(delta:float) -> void:
	if Input.is_action_just_pressed("dash"):
		_do_dash()


func _physics_process(delta: float) -> void:
	if not in_animation:
		_control(delta)	
	
	#if velocity != Vector2.ZERO:
		#play_footstep()
				
	move_and_slide()
	
	#if not in_animation:
		#_update_sprite()
	

func _do_dash()->void:
	if not $DashTimer.is_stopped():
		return
	$DashTimer.start()
	xsm.change_state("dash")
