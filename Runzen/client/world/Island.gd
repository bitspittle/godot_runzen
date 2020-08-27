extends Spatial

onready var _player = $Player

func _ready():
	_player.current_path = $Path2
