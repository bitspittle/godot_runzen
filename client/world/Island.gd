extends Spatial

onready var _player = $Players/Player
onready var _grass = $Grass

onready var _trees = $Trees

var _tree_scene = preload("res://client/world/Tree.tscn")

func _ready():
	randomize()
	for i in range(100):
		var x = rand_range(-40, 40)
		var z = rand_range(-40, 40)
		var y = rand_range(0.6, 1.0)

		var tree = _tree_scene.instance()
		tree.transform.origin.x = x
		tree.transform.origin.z = z
		tree.scale.y = y
		tree.rotation.y = rand_range(0, 2 * PI)
		_trees.add_child(tree)

	_player.current_path = $TestPath
