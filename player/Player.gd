extends KinematicBody

var turning_speed = PI / 2
var running_speed = 500

var GRAVITY = Vector3.DOWN * 10

func _physics_process(delta):
	var turn_input = Input.get_action_strength("player_turn_left") - Input.get_action_strength("player_turn_right")
	if turn_input != 0:
		rotation.y += turn_input * turning_speed * delta

	var move_input = Input.get_action_strength("player_backward") - Input.get_action_strength("player_forward")
	var direction = Vector3.ZERO
	if move_input != 0:
		var rad = rotation.y
		direction = Vector3(move_input * sin(rad), 0, move_input * cos(rad))

	direction += GRAVITY
	move_and_slide(direction * running_speed * delta, Vector3.UP)
