extends Node


@warning_ignore("unused_signal")
signal map_changed
@warning_ignore("unused_signal")
signal map_scored(score: MapScore)
@warning_ignore("unused_signal")
signal button_clicked


@warning_ignore("unused_signal")
signal on_transition_state_change(value:bool)
@warning_ignore("unused_signal")
signal on_hint_found()
@warning_ignore("unused_signal")
signal on_landmark_found(landmark:Landmark)

@warning_ignore("unused_signal")
signal timer_timeout()

@warning_ignore("unused_signal")
signal timer_countdown()

@warning_ignore("unused_signal")
signal confirmation_requested(door:WorldDoor)

@warning_ignore("unused_signal")
signal tutorial_requested(step:Types.TutorialSteps)
