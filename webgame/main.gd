extends Node3D

# Minimal solo loop: survive the countdown. (No seeker yet — that's the online
# version.) Just gives the demo a goal.

@onready var _timer_label: Label = get_tree().get_first_node_in_group("timer_label")

var _time_left: float = 90.0
var _done: bool = false

func _process(delta: float) -> void:
	if _done:
		return
	_time_left -= delta
	if _time_left <= 0.0:
		_done = true
		if _timer_label:
			_timer_label.text = "You survived! (refresh to replay)"
		return
	if _timer_label:
		var s: int = int(ceil(_time_left))
		_timer_label.text = "Survive: %d:%02d" % [s / 60, s % 60]
