extends KinematicBody

const PERIOD_SECS = 0.5
const NOISE_FILTER = 0.5
var GRAVITY = Vector3.DOWN * 10

var turning_speed = PI / 2
var running_speed = 10

var _half_steps_buffer = CircularBuffer.new()
var _steps_per_sec = 0.0

var acc_history = CircularBuffer.new()

var _period_remaining = PERIOD_SECS

var _turn_input = 0

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
	acc_history.append(Input.get_accelerometer())

	_period_remaining -= delta
	if _period_remaining < 0:
		_period_remaining = PERIOD_SECS

		var last_min = 0.0
		var last_max = 0.0

		var last_section = 0 # -1 = negative, 1 = positive, 0 = uninitialized
		for i in acc_history.size():
			var acc: Vector3 = acc_history.get_item(i)

			var curr_section = sign(acc.x)
			if curr_section < 0:
				last_min = min(last_min, acc.x)
			elif curr_section > 0:
				last_max = max(last_max, acc.x)

			if last_section != 0 && curr_section != last_section:
				if curr_section < 0: # We just changed from max to min
					_half_steps_buffer.append(last_max)
					last_max = 0.0
				elif curr_section > 0:
					_half_steps_buffer.append(last_min)
					last_min = 0.0

			last_section = curr_section
		acc_history.clear()

		var half_steps = 0
		for half_step in _half_steps_buffer.iter():
			print(abs(half_step), " > ", NOISE_FILTER, "?")
			if abs(half_step) > NOISE_FILTER:
				half_steps += 1

		_steps_per_sec = (half_steps / 2.0) / PERIOD_SECS

		_half_steps_buffer.clear()

func _physics_process(delta):
	var turn_input = _turn_input
	if OS.is_debug_build():
		var turn_override = Input.get_action_strength("player_turn_right") - Input.get_action_strength("player_turn_left")
		if turn_override != 0:
			turn_input = turn_override

	if turn_input != 0:
		rotation.y += -turn_input * turning_speed * delta

	var move_magnitude = -_steps_per_sec
	var direction = Vector3.ZERO

	if OS.is_debug_build():
		var move_override = Input.get_action_strength("player_backward") - Input.get_action_strength("player_forward")
		if move_override != 0:
			move_magnitude = move_override * 100

	if move_magnitude != 0:
		var rad = rotation.y
		direction = Vector3(move_magnitude * sin(rad), 0, move_magnitude * cos(rad))

	direction += GRAVITY
	move_and_slide(direction * running_speed * delta, Vector3.UP)

	if is_on_wall():
		rotation.y += PI
