extends Node

func _ready():
	if OsUtils.is_mobile():
		OS.keep_screen_on = true

	if CmdLineArgs.is_set("--server"):
		get_tree().change_scene("res://server/Server.tscn")
	elif CmdLineArgs.is_set("--controller"):
		get_tree().change_scene("res://controller/screens/start/PairController.tscn")
	elif CmdLineArgs.is_set("--local"):
		get_tree().change_scene("res://client/world/Island.tscn")
	else:
		get_tree().change_scene("res://client/screens/start/WaitForPairing.tscn")
