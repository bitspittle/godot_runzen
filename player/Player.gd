extends KinematicBody

const PERIOD_SECS = 0.5
const NOISE_FILTER = 0.2
const STEP_DETECTING_SECS = 0.5 # If no step after this many secs, we stop
var GRAVITY = Vector3.DOWN * 9.8

var turning_speed = PI / 2 # radians per sec

var _period_remaining = PERIOD_SECS
# Steps are like waves, and we detect the peaks and troughs of those waves
var _acc_sign = 0 # 0 = uninitialized, -1 stepping down, 1 stepping up
var _turn_input = 0
var _half_steps = CircularBuffer.new() # List of arrays, [t, step_peak]

var _velocity = Vector3.ZERO

var _last_min = 0.0
var _last_max = 0.0
var _elapsed = 0

var _is_mobile: bool

onready var _rest_timer = $RestTimer

func _ready():
	_is_mobile = OS.get_name() == "Android"

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < (OS.get_screen_size().x / 2):
				_turn_input = -1
			else:
				_turn_input = 1
		else:
			_turn_input = 0

func _process(delta):
	_elapsed += delta

	if _is_mobile:
		var acc = Input.get_accelerometer()
		var grav = Input.get_gravity()
		# Offsetting "1.0" handles the fact that gravity is always pulling down on the device, I think
		var acc_len = Vector3Util.proj_len(grav, acc) - 1.0

		if abs(acc_len) >= NOISE_FILTER:
			print(acc_len)
			_process_acc(acc_len)
	else:
		if Input.is_action_just_pressed("player_forward"):
			_rest_timer.start(STEP_DETECTING_SECS)
			_half_steps.append([_elapsed, -10])
		elif Input.is_action_just_released("player_backward"):
			_rest_timer.start(STEP_DETECTING_SECS)
			_half_steps.append([_elapsed, 10])

	_prune_old_steps()

func _process_acc(acc_len: float):
	_rest_timer.start(STEP_DETECTING_SECS)

	var acc_sign = sign(acc_len)
	if _acc_sign == 0:
		_acc_sign = acc_sign

	if _acc_sign != acc_sign:
		if _acc_sign < 0:
			# We finished a down step
			_half_steps.append([_elapsed, _last_min])
			_last_min = 0.0
		else:
			# We finished an up step
			_half_steps.append([_elapsed, _last_max])
			_last_max = 0.0
		_acc_sign = acc_sign

	if acc_sign < 0:
		_last_min = min(_last_min, acc_len)
	else:
		_last_max = max(_last_max, acc_len)

func _prune_old_steps():
	var prune_before = _elapsed - 1.0
	while !_half_steps.empty() &&_half_steps.get_item(0)[0] < prune_before:
		_half_steps.remove_first()

func _physics_process(delta):
	var turn_input = _turn_input
	if OS.is_debug_build():
		var turn_override = Input.get_action_strength("player_turn_right") - Input.get_action_strength("player_turn_left")
		if turn_override != 0:
			turn_input = turn_override
#
	if turn_input != 0:
		rotation.y += -turn_input * turning_speed * delta

	var steps_per_sec = _half_steps.size() / 2.0
	var move_magnitude = -steps_per_sec

	if move_magnitude != 0:
		var rad = rotation.y
		_velocity = Vector3(move_magnitude * sin(rad), 0, move_magnitude * cos(rad))
	_velocity += GRAVITY * delta
	_velocity = move_and_slide(_velocity, Vector3.UP)

	if is_on_wall():
		rotation.y += PI

func _on_RestTimer_timeout():
	_half_steps.clear()
	_velocity.x = 0
	_velocity.z = 0
