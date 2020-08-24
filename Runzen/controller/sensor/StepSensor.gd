# Class for abstracting step data from accelerometer / gravity sensors
extends Node

const _NOISE_FILTER = 0.2 # Remove sensor noise
const _FAKE_STEPS_DELTA = 2.0 # Steps added per debug steps increased / decreased

signal half_step_taken(magnitude)

# Steps are like waves, and we detect the peaks and troughs of those waves
var _acc_sign = 0 # 0 = uninitialized, -1 stepping down, 1 stepping up
var _last_min = 0.0
var _last_max = 0.0

var _elapsed = 0

func _ready():
	if !OsUtils.is_mobile():
		push_error("StepSensor only supported on mobile devices")

func _process(delta):
	_elapsed += delta

	var acc = Input.get_accelerometer()
	var grav = Input.get_gravity()
	# Offsetting "1.0" handles the fact that gravity is always pulling down on
	# the device. See also:
	# https://developer.android.com/guide/topics/sensors/sensors_motion#sensors-raw-data
	var magnitude = Vector3Util.proj_len(grav, acc) - 1.0
	if abs(magnitude) > _NOISE_FILTER:
		_process_accelerator_magnitude(magnitude)

func _process_accelerator_magnitude(acc_magn: float) -> void:
	var acc_sign = sign(acc_magn)
	if _acc_sign == 0:
		_acc_sign = acc_sign

	if _acc_sign != acc_sign:
		if _acc_sign < 0:
			# We finished a down step
			emit_signal("half_step_taken", _last_min)
			_last_min = 0.0
		else:
			# We finished an up step
			emit_signal("half_step_taken", _last_max)
			_last_max = 0.0
		_acc_sign = acc_sign

	if acc_sign < 0:
		_last_min = min(_last_min, acc_magn)
	else:
		_last_max = max(_last_max, acc_magn)
