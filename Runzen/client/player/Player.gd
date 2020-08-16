extends KinematicBody

const METERS_PER_STEP = 0.7
const _DEBUG_STEPS_PER_SEC = 10.0

var _elapsed = 0.0
var _distance = 0.0

var current_path: Path = null setget _set_current_path

onready var _follow = $PathFollow

onready var _camera = $Eye/EyeCamera
onready var _camera_parent = $Eye
onready var _mph_label = $Control/Panel/MphLabel
onready var _steps_label = $Control/Panel/StepsLabel
onready var _mph_label_format = _mph_label.text
onready var _steps_label_format = _steps_label.text

onready var _client = SyncRoot.find_client(NetUtils.get_unique_id(self))
onready var _ground_detector = $GroundDetector

func _ready():
	_update_ui()

func _set_current_path(path: Path):
	if current_path != null:
		current_path.enqueue_free()

	# Make our own copy of the path and autocalculate curves
	current_path = Path.new()
	current_path.curve = Curve3D.new()

	for i in path.curve.get_point_count():
		var beforei = i - 1
		if beforei < 0:
			beforei += path.curve.get_point_count()
		var afteri = i + 1
		if afteri == path.curve.get_point_count():
			afteri = 0

		var curr = path.curve.get_point_position(i)
		var before = path.curve.get_point_position(beforei)
		var after = path.curve.get_point_position(afteri)

		var after_delta = (after - curr)
		var before_delta = (before - curr)
		var avg = ((after_delta.normalized() + before_delta.normalized()) / 2.0).normalized()

		var is_right_turn = (before_delta.cross(after_delta).y) >= 0

		var turn_angle = PI / 2.0
		if !is_right_turn:
			turn_angle = -turn_angle

		var smaller_delta = after_delta
		if (after_delta.length_squared() > before_delta.length_squared()):
			smaller_delta = before_delta

		var control_out = avg.rotated(Vector3.UP, turn_angle).normalized() * (smaller_delta.length() / 5.0)
		var control_in = -control_out

		current_path.curve.add_point(path.curve.get_point_position(i), control_in, control_out)

	# Close the loop!
	current_path.curve.add_point(current_path.curve.get_point_position(0), current_path.curve.get_point_in(0), current_path.curve.get_point_out(0))
	path.get_parent().add_child(current_path)

	_follow.get_parent().remove_child(_follow)
	current_path.add_child(_follow)
	_snap_to_follow()

func _snap_to_follow():
	translation.x = _follow.translation.x
	translation.z = _follow.translation.z
	if _ground_detector.is_colliding():
		translation.y = _ground_detector.get_collision_point().y
	_camera_parent.rotation.y = _follow.rotation.y + (PI/2)

func _steps_per_sec():
	if _client == null: return _DEBUG_STEPS_PER_SEC
	return _client.steps_per_sec.value

func _physics_process(delta):
	var steps_per_sec = _steps_per_sec()
	if steps_per_sec > 0:
		_distance += steps_per_sec * METERS_PER_STEP * delta
		_follow.offset = _distance
		_snap_to_follow()
		var vel = Vector3(0.0, -9.8, 0.0)
		vel = move_and_collide(vel * delta)

func _update_ui():
	var miles = _distance * 0.000621371
	_mph_label.text = _mph_label_format % miles
	_steps_label.text = _steps_label_format % _steps_per_sec()

func _on_UpdateUiTimer_timeout():
	_update_ui()
