extends KinematicBody

const PERIOD_SECS = 0.5
const REST_DETECTING_SECS = 0.5 # If no step after this many secs, we stop
const METERS_PER_STEP = 0.3
var GRAVITY = Vector3.DOWN * 9.8

# How fast player can turn if standing still. The faster they move, the slower
# they can turn
const STANDING_TURNING_SPEED = PI # radians per sec

var _velocity = Vector3.ZERO

# A buffer of arrays: [t, half_step_magnitude]
# Will regularly be trimmed so we get a running window of how many steps a player
# takes per time period
var _half_steps_buffer = CircularBuffer.new()
var _elapsed = 0.0

var _waypoint_scene = preload("res://path/Waypoint.tscn")
var _waypoints = []
var current_path: Path = null setget _set_current_path

onready var _rest_timer = $RestTimer
onready var _follow = $PathFollow

func _set_current_path(path: Path):
	for waypoint in _waypoints:
		waypoint.queue_free()
		_waypoints.clear()

	current_path = path
	for i in range(current_path.curve.get_point_count()):
		var pt = current_path.curve.get_point_position(i)
		var waypoint = _waypoint_scene.instance()
		waypoint.translation.x = pt.x
		waypoint.translation.z = pt.z
		waypoint.translation.y = 2.0
		_waypoints.append(waypoint)
		get_parent().add_child(waypoint)

	_follow.get_parent().remove_child(_follow)
	current_path.add_child(_follow)
	_follow.offset = 0.0001 # Force follow to snap after adding
	_snap_to_follow()

func _process(delta):
	_elapsed += delta
	_prune_old_steps()

func _prune_old_steps():
	var prune_if_before = _elapsed - 1.0
	while !_half_steps_buffer.empty() \
	&& _half_steps_buffer.get_item(0)[0] < prune_if_before:
		_half_steps_buffer.remove_first()

func _snap_to_follow():
	translation.x = _follow.translation.x
	translation.z = _follow.translation.z
	rotation.y = _follow.rotation.y

func _physics_process(delta):
	var steps_per_sec = _half_steps_buffer.size() / 2.0
	if steps_per_sec > 0:
		_follow.offset += (steps_per_sec) * delta
		_snap_to_follow()

#func _physics_process(delta):
#	var steps_per_sec = _half_steps_buffer.size() / 2.0
#
#	var rot_y = rotation.y
#	var pos_vector = Vector2(self.translation.x, self.translation.z)
#	var dir_vector = Vector2(sin(rot_y), cos(rot_y))
#	var to_waypoint_vector = Vector2(_next_waypoint_pos.x, _next_waypoint_pos.z) - pos_vector
#
#	var turn_angle = dir_vector.angle_to(to_waypoint_vector)
#
#	throttle += 1
#	if throttle == 10:
#		print(turn_angle)
#		throttle = 0
#
#	if abs(turn_angle) > 0.01:
#		if turn_angle < 0:
#			turn_angle += 2.0 * PI
#		var turn_direction = -1
#		if turn_angle > PI:
#			turn_direction = 1
#		var turning_speed = STANDING_TURNING_SPEED / (1 + (steps_per_sec / 4))
#		var clamped_turning_speed = min(turning_speed, turn_angle)
#		rotation.y += (turn_direction) * clamped_turning_speed * delta
#
#	if (self.translation - _next_waypoint_pos).length_squared() <= 3.0:
#		_update_next_waypoint()
#
#	var move_magnitude = steps_per_sec
#
#	if move_magnitude != 0:
#		rot_y = rotation.y
#		_velocity = Vector3(move_magnitude * sin(rot_y), 0, move_magnitude * cos(rot_y))
#	_velocity += GRAVITY * delta
#	_velocity = move_and_slide(_velocity, Vector3.UP)

func _on_RestTimer_timeout():
	_half_steps_buffer.clear()
	_velocity.x = 0
	_velocity.z = 0


func _on_StepSensor_half_step_taken(magnitude):
	_half_steps_buffer.append([_elapsed, magnitude])
	_rest_timer.start()
