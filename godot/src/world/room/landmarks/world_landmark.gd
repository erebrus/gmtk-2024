extends StaticBody2D

var data:Landmark


func _on_area_2d_body_entered(_body: Node2D) -> void:
	Logger.info("Found landmark.")
	data.found = true
	Events.on_landmark_found.emit(data)
	$Area2D.collision_mask=0
	$Area2D/CollisionShape2D.set_deferred("disabled", true)


func update_state():
	if data.found:
		$Area2D.collision_mask=0
		$Area2D/CollisionShape2D.disabled = true	
