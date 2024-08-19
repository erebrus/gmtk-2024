extends CharacterBody2D
class_name Player

@export var rc_distance := 50.0
@export var dash_impulse:float = 1200
@export var walk_speed:float = 200	
@export var run_speed:float = 400
#@export var max_hp:float = 150

@onready var xsm = $xsm
@onready var anim_tree:AnimationTree = $AnimationTree
@onready var anim_player:AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite
@onready var wall_rc: RayCast2D = $wall_rc

@onready var sfx_walk: AudioStreamPlayer2D = $sfx/sfx_walk
@onready var sfx_hint: AudioStreamPlayer2D = $sfx/sfx_hint
@onready var sfx_hurt: AudioStreamPlayer2D = $sfx/sfx_hurt
@onready var sfx_dash: AudioStreamPlayer2D = $sfx/sfx_dash
@onready var sfx_landmark: AudioStreamPlayer2D = $sfx/sfx_landmark



var last_direction:Vector2 = Vector2.UP:
	set(v):
		last_direction=v
		wall_rc.target_position=last_direction * rc_distance

var in_animation:bool = false
#@onready var hp:float = max_hp

func _ready():
	Globals.player = self
	Events.on_hint_found.connect(_on_hint_found)
	Events.on_landmark_found.connect(_on_landmark_found)
	#Events.on_transition_state_change.connect(_on_transition_state_change)
	
func _on_hint_found():
	sfx_hint.play()
	Globals.current_hints += 1
	Logger.info("Clues found:%s" % Globals.last_landmarks)
	
func _on_landmark_found(_landmark):
	sfx_landmark.play()
	$Label.visible = true
	$Label.modulate=Color(1,1,1,1)
	var tween=get_tree().create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property($Label,"modulate",Color(1,1,1,0),2)
	Globals.last_landmarks[Globals.current_room.cell]=_landmark.type
	Logger.info("Landmarks found:%s" % Globals.last_landmarks)
	
func _on_transition_state_change(state:bool):
	in_animation=state
	collision_layer=0 if state else 1
	
func _control(_delta:float) -> void:
	if Input.is_action_just_pressed("dash"):
		_do_dash()

func can_move()->bool:
	return not wall_rc.is_colliding()
	
func _physics_process(delta: float) -> void:
	if not in_animation:
		_control(delta)	
	
	
	#if velocity != Vector2.ZERO:
		#play_footstep()
				
	move_and_slide()
	
	#if not in_animation:
		#_update_sprite()
	
func update_sprite():
	$CollisionShape2D.rotation=last_direction.angle()+PI/2
	$CollisionShape2D.position=last_direction*5
	if last_direction.x==0 or last_direction.y==0:
		sprite.flip_h=false
		sprite.flip_v=false
		if last_direction.y < 0:
			sprite.rotation=0
		elif last_direction.y > 0:
			sprite.rotation=PI
		elif last_direction.x < 0:
			sprite.rotation=-PI/2
		elif last_direction.x > 0:
			sprite.rotation=PI/2
	else:
		sprite.rotation=0
		if last_direction.x < -.5 and last_direction.y < -.5:
			sprite.flip_h=false
			sprite.flip_v=false
		elif last_direction.x > .5 and last_direction.y > .5:
			sprite.flip_h=true
			sprite.flip_v=true
		elif last_direction.x < -.5 and last_direction.y > .5:
			sprite.flip_h=false
			sprite.flip_v=true
		elif last_direction.x > .5 and last_direction.y < -.5:
			sprite.flip_h=true
			sprite.flip_v=false
			
func _do_dash()->void:
	if not $DashTimer.is_stopped():
		return
	$DashTimer.start()
	xsm.change_state("dash")
