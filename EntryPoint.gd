extends Node

func _ready():
	if CmdLineArgs.is_set("--server"):
		pass
	elif CmdLineArgs.is_set("--controller"):
		pass
	else:
		get_tree().change_scene("res://client/world/Island.tscn")
