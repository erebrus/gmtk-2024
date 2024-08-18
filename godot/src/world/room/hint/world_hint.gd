extends Area2D

var data:Hint


func _on_body_entered(_body: Node2D) -> void:
	Logger.info("Found hint.")
	Events.on_hint_found.emit()
	data.found = true
	collision_mask=0
	$CollisionShape2D.disabled = true
	call_deferred("queue_free")
