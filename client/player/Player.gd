extends KinematicBody

const METERS_PER_STEP = 0.7

var _elapsed = 0.0
var _distance = 0.0

var current_path: Path = null setget _set_current_path

onready var _follow = $PathFollow

onready var _camera = $EyeCamera
onready var _mph_label = $Control/Panel/MphLabel
onready var _steps_label = $Control/Panel/StepsLabel
onready var _mph_label_format = _mph_label.text
onready var _steps_label_format = _steps_label.text

onready var _client = SyncRoot.find_client(NetUtils.get_unique_id(self))
onready var _ground_detector = $GroundDetector
onready var _rotation_tween = $RotationTween

func _ready():
	_update_ui()

func _set_current_path(path: Path):
	current_path = path

	_follow.get_parent().remove_child(_follow)
	current_path.add_child(_follow)
	_follow.offset = 0.0001 # Force follow to snap after adding
	_snap_to_follow(true)

func _snap_to_follow(immediate_rotation: bool = false):
	translation.x = _follow.translation.x
	translation.z = _follow.translation.z
	translation.y = _ground_detector.get_collision_point().y

	if immediate_rotation:
		rotation.y = _follow.rotation.y
	elif rotation.y != _follow.rotation.y && !_rotation_tween.is_active():
		var angle_diff = _follow.rotation.y - rotation.y
		if angle_diff < 0.0:
			angle_diff += (2.0 * PI)

		var rotation_target = rotation.y
		if angle_diff <= PI:
			# Turn left
			rotation_target += angle_diff
		else:
			rotation_target -= (2.0 * PI - angle_diff)

		_rotation_tween.interpolate_property(self, "rotation:y", rotation.y,rotation_target, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		_rotation_tween.start()

func _steps_per_sec():
	if _client == null: return 20.0
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
