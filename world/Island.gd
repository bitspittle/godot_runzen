extends Spatial

onready var _player = $Players/Player
onready var _camera = $Camera

func _physics_process(delta):
	_camera.look_at(_player.translation, Vector3.UP)
