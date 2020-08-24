extends Panel

var _elapsed = 0.0

onready var _controller = SyncRoot.find_controller(NetUtils.get_unique_id(self))

func _process(delta):
	_elapsed += delta

func _on_StepSensor_half_step_taken(magnitude):
	_controller.steps_per_sec.value = [_elapsed, magnitude]

