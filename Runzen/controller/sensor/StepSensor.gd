# Class for abstracting step data from accelerometer / gravity sensors
extends Node

const _FILTER_MIN = 0.3 # Amount where we can't tell noise from signal
const _CLEAR_MAX = -99999.9
const _CLEAR_MIN = 99999.9

signal step_taken(magnitude)

# Filter will temporarily increase when we start to detect steps
var _curr_filter = _FILTER_MIN
var _curr_min = _CLEAR_MIN
var _curr_max = _CLEAR_MAX

# Acceleration magnitudes measured...
var _i = 0 # 2 frames ago
var _j = 0 # one frame ago
var _k = 0 # this frame

func _ready():
	if !OsUtils.is_mobile():
		push_error("StepSensor only supported on mobile devices")

func _process(delta):
	_curr_filter -= (delta * 2.0)
	_curr_filter = max(_FILTER_MIN, _curr_filter)
	
	var acc = Input.get_accelerometer()
	var grav = Input.get_gravity()

	_i = _j
	_j = _k
	# Offsetting "1.0" handles the fact that gravity is always pulling down on
	# the device. See also:
	# https://developer.android.com/guide/topics/sensors/sensors_motion#sensors-raw-data
	_k = Vector3Util.proj_len(grav, acc) - 1.0

	if _i <= _j && _j > _k:
		_curr_max = max(_curr_max, _j)
		var magnitude = _curr_max - _curr_min
		if magnitude > _curr_filter:
			_curr_filter = 0.8 * magnitude
			_curr_min = _CLEAR_MIN
			emit_signal("step_taken", magnitude)
	elif _i >= _j && _j < _k:
		_curr_min = min(_curr_min, _j)
		var magnitude = _curr_max - _curr_min
		if magnitude > _curr_filter:
			_curr_max = _CLEAR_MAX
