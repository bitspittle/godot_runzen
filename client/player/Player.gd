extends KinematicBody

const METERS_PER_STEP = 0.7

var _elapsed = 0.0
var _distance = 0.0

var _waypoint_scene = preload("res://client/path/Waypoint.tscn")
var _waypoints = []
var current_path: Path = null setget _set_current_path

onready var _follow = $PathFollow

onready var _mph_label = $Control/Panel/MphLabel
onready var _steps_label = $Control/Panel/StepsLabel
onready var _mph_label_format = _mph_label.text
onready var _steps_label_format = _steps_label.text

onready var _client = SyncRoot.find_client(NetUtils.get_unique_id(self))

func _ready():
	_update_ui()

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

func _snap_to_follow():
	translation.x = _follow.translation.x
	translation.z = _follow.translation.z
	rotation.y = _follow.rotation.y

func _steps_per_sec():
	return _client.steps_per_sec.value

func _physics_process(delta):
	var steps_per_sec = _steps_per_sec()
	if steps_per_sec > 0:
		_distance += steps_per_sec * METERS_PER_STEP * delta
		_follow.offset = _distance
		_snap_to_follow()

func _update_ui():
	var miles = _distance * 0.000621371
	_mph_label.text = _mph_label_format % miles
	_steps_label.text = _steps_label_format % _steps_per_sec()

func _on_UpdateUiTimer_timeout():
	_update_ui()
