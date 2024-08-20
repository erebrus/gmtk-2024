extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play_random()



func play_random():
	$AnimationPlayer.play("anim"+str(randi_range(1,5)))


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	play_random()
