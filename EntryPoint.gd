extends Node

func _ready():
	if CmdLineArgs.is_set("--server"):
		get_tree().change_scene("res://server/Server.tscn")
	elif CmdLineArgs.is_set("--controller"):
		get_tree().change_scene("res://controller/start/PairController.tscn")
	else:
		get_tree().change_scene("res://client/start/WaitForPairing.tscn")
