extends Panel

const REST_SECS = 1.0 # After this many seconds of no steps, stop!
const PERIOD_SECS = 2.0

# A buffer of arrays: [t, half_step_magnitude]
# Will regularly be trimmed so we get a running window of how many steps a player
# takes per time period
var _half_steps_buffer = CircularBuffer.new()
var _elapsed = 0.0

onready var _rest_timer = $RestTimer
onready var _controller = SyncRoot.find_controller(NetUtils.get_unique_id(self))
onready var _footsteps = $FootstepsAudio

func _ready():
	_rest_timer.wait_time = REST_SECS

func _process(delta):
	_elapsed += delta
	_prune_old_steps()

	_controller.steps_per_sec.value = (_half_steps_buffer.size() / 2.0) / PERIOD_SECS

func _prune_old_steps():
	var prune_if_before = _elapsed - PERIOD_SECS
	while !_half_steps_buffer.empty() \
	&& _half_steps_buffer.get_item(0)[0] < prune_if_before:
		_half_steps_buffer.remove_first()

func _on_StepSensor_half_step_taken(magnitude):
	_half_steps_buffer.append([_elapsed, magnitude])
	_rest_timer.start()
	_footsteps.step()

func _calc_steps_per_sec() -> float:
	return (_half_steps_buffer.size() / 2.0) / PERIOD_SECS

func _on_RestTimer_timeout():
	_half_steps_buffer.clear()
