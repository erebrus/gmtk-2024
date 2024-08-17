extends State

func _ready() -> void:
	await get_tree().process_frame
	super._ready()
	
