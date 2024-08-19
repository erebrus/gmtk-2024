extends Node


enum MapMode {
	Rooms,
	Doors,
	Landmarks
}

enum Traps {
	NONE,
	TRAP1,
	}

enum Landmarks {
	FOUNTAIN, 
	BONES,
	BUTTON_RED,
	BUTTON_GREEN,
	
}

const LANDMARK_TEXTURES = {
	Landmarks.FOUNTAIN: preload("res://assets/gfx/ui/icons/fountain.png"),
	Landmarks.BONES: preload("res://assets/gfx/ui/icons/skull.png"),
}
