extends Area2D

var data:Hint


func _on_body_entered(_body: Node2D) -> void:
	Logger.info("Found hint.")
	data.found = true	
	Events.on_hint_found.emit()	
	Events.tutorial_requested.emit(Types.TutorialSteps.CHEESE)
	call_deferred("queue_free")
