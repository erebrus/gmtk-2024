extends PanelContainer


const LEADERBOARD_KEY = "gmtk2024"


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
	
	%RoomsScore.text = grade(score.rooms)
	%DoorsScore.text = grade(score.doors)
	if score.has_special():
		%SpecialScore.text = grade(score.special)
	else:
		%SpecialScore.text = "-"
	
	
	
	if score.total > min_accuracy[passing_grade]:
		$SuccessSFX.play()
		%ContinueButton.show()
	else:
		$FailureSFX.play()
		%ContinueButton.hide()

	var old_score = Globals.score.score
	%TotalScore.text = "%d" % Globals.score.score		
	Globals.bonus_time_factor = bonus_time_factor[grade(score.total)]
	Globals.score.score_level(Globals.current_level,grade(score.total), Globals.dungeon.get_hint_count(true))
	submit_score(Globals.score.score)
	
	var cheese_str:=""
	for i in Globals.dungeon.get_hint_count(true):
		cheese_str += "+"
	if cheese_str == "":
		cheese_str = "-"
	%CheeseScore.text = cheese_str	
	
	var level_score:int = Globals.score.level_scores[Globals.current_level]
	%ScoreLabel.text = "%d" % level_score
	var tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_method(update_score_label,old_score, Globals.score.score,.5+round(float(level_score)/2000.0))

func update_score_label(value:int):
	%TotalScore.text = "%d" % value
	
func grade(score: float) -> String:
	var grade = "F"
	for g in min_accuracy:
		if score > min_accuracy[g]:
			grade = g
	return grade
	

func submit_score(score: int):
	Globals.in_game = false
	var previous = await LootLocker.leaderboard.get_player_score(LEADERBOARD_KEY)
	
	var is_highscore = previous == null or previous.score < score
	
	if is_highscore:
		await LootLocker.leaderboard.upload_player_score(LEADERBOARD_KEY, score)
	
	

func _on_continue_button_pressed():
	Events.button_clicked.emit()
	
	Globals.next_level() 


func _on_retry_button_pressed():
	Events.button_clicked.emit()
	Globals.retry_level()
