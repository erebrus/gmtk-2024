class_name MapNumScore extends RefCounted
const cheese_score := 200
const grade_score:= {
	"E"= 100,
	"D"= 300,
	"C"= 500,
	"B"= 700,
	"A"= 1000,
	"S"= 2000,
}

const level_score_factor := [1,1.05,1.07,1.1,1.15,1.2,1.25,1.3]

var level_scores=[0,0,0,0,0,0,0,0]

var score:int:
	get:		
		score = level_scores.reduce(func(accum, number): return accum + number, 0)
		return score
	set(v):
		pass

	
func score_level(level:int, grade:String, cheeses :=0):
	if level >= level_scores.size():
		Logger.error("Tried to score invalid level:%d" % level)
		return
	var level_score := 0
	if grade in grade_score:
		level_scores[level] = grade_score[grade] * level_score_factor[level] + cheeses * cheese_score
		Logger.info("Score for level %d is now %d" % [level, level_scores[level]])
	else:
		Logger.error("Tried to score invalid grade:%s" % grade)
