extends CharacterBody2D
class_name Player

@export var dash_impulse:float = 1200
@export var walk_speed:float = 100	
@export var run_speed:float = 200
#@export var max_hp:float = 150

@onready var xsm = $xsm
@onready var anim_tree:AnimationTree = $AnimationTree
@onready var anim_player:AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite

@onready var sfx_walk: AudioStreamPlayer2D = $sfx/sfx_walk
@onready var sfx_dash: AudioStreamPlayer2D = $sfx/sfx_dash



var last_direction:Vector2 = Vector2.UP
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
	
	if not in_animation:
		_update_sprite()
	

func _update_sprite():
	if last_direction.y < 0:
		sprite.rotation=0
	elif last_direction.y > 0:
		sprite.rotation=PI
	elif last_direction.x < 0:
			sprite.rotation=-PI/2
	elif last_direction.x > 0:
			sprite.rotation=PI/2
			
func _do_dash()->void:
	if not $DashTimer.is_stopped():
		return
	$DashTimer.start()
	xsm.change_state("dash")
