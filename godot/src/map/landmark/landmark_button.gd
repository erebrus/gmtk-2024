@tool
extends DraggableButton

@export var landmark_type: Types.Landmarks:
	set(value):
		if value == landmark_type:
			return
		landmark_type = value
		region_rect.position.x = (landmark_type-1) * region_rect.size.y
	

func _create_scene() -> Node:
	var landmark: MapLandmark = super._create_scene()
	landmark.landmark_type = landmark_type
	dungeon.add_landmark.call_deferred(landmark)
	
	return landmark
	
