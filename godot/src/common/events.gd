extends Node


@warning_ignore("unused_signal")
signal map_mode_changed
@warning_ignore("unused_signal")
signal map_changed

@warning_ignore("unused_signal")
signal on_transition_state_change(value:bool)
signal on_hint_found()
signal on_landmark_found(landmark:Landmark)
