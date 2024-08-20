extends PanelContainer


@export_category("Score")
@export var min_accuracy = {
	"E"= 0.3,
	"D"= 0.5,
	"C"= 0.7,
	"B"= 0.8,
	"A"= 0.9,
	"S"= 0.999,
}

@export var passing_grade := "C"

@export var bonus_time_factor = {
	"E"= 0,
	"D"= 0,
	"C"= 0,
	"B"= .05,
	"A"= .1,
	"S"= .2,
}

var time:= 0


func _ready() -> void:
	Events.map_scored.connect(_on_map_scored)
	%RetryButton.pressed.connect(_on_retry_button_pressed)
	%ContinueButton.pressed.connect(_on_continue_button_pressed)
	

func _on_map_scored(score: MapScore) -> void:
	%RoomsScore.text = ""
	%DoorsScore.text =  ""
	%SpecialScore.text = ""
	%ScoreLabel.text = ""
	
	# TODO fancy animation with scores showing one by one?
	show()
	
	%RoomsScore.text = _grade(score.rooms)
	%DoorsScore.text = _grade(score.doors)
	if score.has_special():
		%SpecialScore.text = _grade(score.special)
	else:
		%SpecialScore.text = "-"
	
	%ScoreLabel.text = _grade(score.total)
	
	if score.total > min_accuracy[passing_grade]:
		$SuccessSFX.play()
		%ContinueButton.show()
	else:
		$FailureSFX.play()
		%ContinueButton.hide()
	
	Globals.bonus_time_factor = bonus_time_factor[_grade(score.total)]
	

func _grade(score: float) -> String:
	var grade = "F"
	for g in min_accuracy:
		if score > min_accuracy[g]:
			grade = g
	return grade
	

func _on_continue_button_pressed():
	Events.button_clicked.emit()
	Globals.next_level() 


func _on_retry_button_pressed():
	Events.button_clicked.emit()
	Globals.retry_level()
