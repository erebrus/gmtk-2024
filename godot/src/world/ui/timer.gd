extends Control

@onready var timer: Timer = $Timer
var time:int:
	set(v):
		time=v
		if countdown_time == -1:
			countdown_time = time /3.0
		update_ui()
		
var countdown_time=-1

func start():
	timer.start()

func update_ui():
	%Label.text="%ds" % time
	
func _on_timer_timeout() -> void:
	self.time -= 1
	if time < 0:
		Events.timer_timeout.emit()
		timer.stop()
	elif time < countdown_time:
		Events.timer_countdown.emit()
		Globals.cross_fade_dungeon_music()
	update_ui()
