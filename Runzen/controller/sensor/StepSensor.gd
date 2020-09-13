# Class for abstracting step data from accelerometer / gravity sensors
extends Node

const _SMOOTH_FACTOR = 5 # Number of neighbors to average against
const _CURVE_SIZE = 5
const _MIN_CURVE_HEIGHT = 0.02
const _MIN_ACC = 0.1

signal step_taken(magnitude)

# Acceleration magnitudes measured...
var _raw_data = CircularBuffer.new(_SMOOTH_FACTOR)
var _smoothed_data = CircularBuffer.new(_CURVE_SIZE)

func _ready():
	if !OsUtils.is_mobile():
		push_error("StepSensor only supported on mobile devices")

func _process(delta):
	var acc = Input.get_accelerometer()
	var grav = Input.get_gravity()

	# Offsetting "1.0" handles the fact that gravity is always pulling down on
	# the device. See also:
	# https://developer.android.com/guide/topics/sensors/sensors_motion#sensors-raw-data
	_raw_data.append(Vector3Util.proj_len(grav, acc) - 1.0)
	
	if _raw_data.is_full():
		var avg = 0.0
		for i in _raw_data.size():
			avg += _raw_data.get_item(i)
		avg /= _raw_data.size()
		_smoothed_data.append(avg)

	if _smoothed_data.is_full():
		var is_curve_top = true
		for i in _smoothed_data.size() / 2:
			var first1 = _smoothed_data.get_item(i)
			var first2 = _smoothed_data.get_item(i + 1)
			if (first1 > first2):
				is_curve_top = false
				break;
				
			var last1 = _smoothed_data.get_item(-(i + 1))
			var last2 = _smoothed_data.get_item(-(i + 2))
			if (last1 > last2):
				is_curve_top = false
				break
				
		if is_curve_top:
			var mid = _smoothed_data.get_item(_smoothed_data.size() / 2)
			var delta1 = mid - _smoothed_data.get_item(0)
			var delta2 = mid - _smoothed_data.get_item(-1)
			
			if (mid >= _MIN_ACC \
			&& delta1 >= _MIN_CURVE_HEIGHT && delta2 >= _MIN_CURVE_HEIGHT):
				emit_signal("step_taken", mid)
				_smoothed_data.clear()
