# Class for abstracting step data from accelerometer / gravity sensors
extends Node

const _NOISE_FILTER = 0.2 # Remove sensor noise
const _FAKE_STEPS_DELTA = 2.0 # Steps added per debug steps increased / decreased

var _is_mobile = false

signal half_step_taken(magnitude)

export var enabled = true

# Used for simulating non-mobile environments
var _fake_steps_per_sec = 0.0
var _fake_step_magnitude = 20.0
var _next_fake_half_step = 0.0
#============================

# Steps are like waves, and we detect the peaks and troughs of those waves
var _acc_sign = 0 # 0 = uninitialized, -1 stepping down, 1 stepping up
var _last_min = 0.0
var _last_max = 0.0

var _elapsed = 0

func _ready():
	_is_mobile = OS.get_name() == "Android"

func _process(delta):
	_elapsed += delta
	if !enabled: return

	if _is_mobile:
		var acc = Input.get_accelerometer()
		var grav = Input.get_gravity()
		# Offsetting "1.0" handles the fact that gravity is always pulling down on the device, I think
		var magnitude = Vector3Util.proj_len(grav, acc) - 1.0
		if abs(magnitude) > _NOISE_FILTER:
			_process_accelerator_magnitude(magnitude)
	else:
		if Input.is_action_just_pressed("debug_player_step_increase"):
			_fake_steps_per_sec += _FAKE_STEPS_DELTA
			_update_next_fake_half_step()
		elif Input.is_action_just_pressed("debug_player_step_decrease"):
			_fake_steps_per_sec -= _FAKE_STEPS_DELTA
			_fake_steps_per_sec = max(_fake_steps_per_sec, 0.0)
		elif Input.is_action_just_pressed("debug_player_stop"):
			_fake_steps_per_sec = 0.0

		if _fake_steps_per_sec > 0.0 && _elapsed >= _next_fake_half_step:
			emit_signal("half_step_taken", _fake_step_magnitude)
			_update_next_fake_half_step()

func _update_next_fake_half_step() -> void:
	_next_fake_half_step = _elapsed + (1.0 / (_fake_steps_per_sec * 2.0))

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
