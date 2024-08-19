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
	Landmarks.BUTTON_RED: preload("res://assets/gfx/ui/icons/button-pink.png"),
	Landmarks.BUTTON_GREEN: preload("res://assets/gfx/ui/icons/button-green.png"),
}

enum TutorialSteps {MOVE, GOAL, TIME, LANDMARK, CHEESE, SIZE, RETURN}

const TUTORIAL_TEXT = {
	TutorialSteps.MOVE : "WASD to move, Space to dash.",
	TutorialSteps.GOAL : "Explore and memorize the maze, so you can map it at scale afterwards.",
	TutorialSteps.TIME : "Make sure to reach the exit before time runs out!",
	TutorialSteps.LANDMARK: "Take note of the landmark and where you found it.",
	TutorialSteps.CHEESE: "Cheese is yummy and gets you extra points.",
	TutorialSteps.SIZE: "Take note of the size of the room. The map must be to SCALE.",
	TutorialSteps.RETURN: "When you are done, leave through the exit."
}
