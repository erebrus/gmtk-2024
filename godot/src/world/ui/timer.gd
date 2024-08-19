extends Control

@onready var timer: Timer = $Timer
var time:int:
	set(v):
		time=v
		if countdown_time == -1:
			countdown_time = time /3.0
		update_ui()
		
var countdown_time=-1
var counting_down := false
func start():
	timer.start()

func update_ui():
	%Label.text="%ds" % time
	
func _on_timer_timeout() -> void:
	self.time -= 1
	if time < 0:
		Events.timer_timeout.emit()
		timer.stop()
	elif time < countdown_time and not counting_down:
		Events.timer_countdown.emit()
		Globals.cross_fade_dungeon_music()
		counting_down=true
	if counting_down:
		$sfx_tick.play()
	update_ui()
