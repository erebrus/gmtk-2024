extends Control

@onready var rooms: Label = $MarginContainer/HBoxContainer/Rooms/HBoxContainer/Rooms
@onready var landmarks: Label = $MarginContainer/HBoxContainer/Landmarks/HBoxContainer/Landmarks
@onready var cheeses: Label = $MarginContainer/HBoxContainer/Cheeses/HBoxContainer/Cheeses


func update_landmarks(found, total):
	landmarks.text = "%d / %d" % [found, total]

func update_cheeses(found, total):
	cheeses.text = "%d / %d" % [found, total]
	
func update_rooms(found, total):
	rooms.text = "%d / %d" % [found, total]
