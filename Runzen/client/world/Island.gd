extends Spatial

onready var _player = $Players/Player

func _ready():
	_player.current_path = $Chunk00_00/Path
