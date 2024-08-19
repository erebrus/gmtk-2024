@tool
extends DraggableButton

@export var landmark_type: Types.Landmarks:
	set(value):
		landmark_type = value
		texture = Types.LANDMARK_TEXTURES[landmark_type]
	

func _create_scene() -> Node:
	var landmark: MapLandmark = super._create_scene()
	landmark.landmark_type = landmark_type
	dungeon.add_landmark.call_deferred(landmark)
	
	return landmark
	
