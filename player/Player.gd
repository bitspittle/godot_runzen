extends KinematicBody

const PERIOD_SECS = 0.5
const REST_DETECTING_SECS = 0.5 # If no step after this many secs, we stop
var GRAVITY = Vector3.DOWN * 9.8

const TURNING_SPEED = PI / 2.0 # radians per sec

var _velocity = Vector3.ZERO

# A buffer of arrays: [t, half_step_magnitude]
# Will regularly be trimmed so we get a running window of how many steps a player
# takes per time period
var _half_steps_buffer = CircularBuffer.new()
var _elapsed = 0.0

onready var _rest_timer = $RestTimer

func _process(delta):
	_elapsed += delta
	_prune_old_steps()

func _prune_old_steps():
	var prune_if_before = _elapsed - 1.0
	while !_half_steps_buffer.empty() \
	&& _half_steps_buffer.get_item(0)[0] < prune_if_before:
		_half_steps_buffer.remove_first()

func _physics_process(delta):
	# TODO: set rotation.y using waypoints
#	rotation.y += -turn_input * turning_speed * delta

	var steps_per_sec = _half_steps_buffer.size() / 2.0
	var move_magnitude = -steps_per_sec

	if move_magnitude != 0:
		var rad = rotation.y
		_velocity = Vector3(move_magnitude * sin(rad), 0, move_magnitude * cos(rad))
	_velocity += GRAVITY * delta
	_velocity = move_and_slide(_velocity, Vector3.UP)

	# TODO: Remove after using waypoints
	if is_on_wall():
		rotation.y += PI

func _on_RestTimer_timeout():
	_half_steps_buffer.clear()
	_velocity.x = 0
	_velocity.z = 0


func _on_StepSensor_half_step_taken(magnitude):
	_half_steps_buffer.append([_elapsed, magnitude])
	_rest_timer.start()
