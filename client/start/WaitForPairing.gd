extends Node

func _ready():
	get_tree().connect("connected_to_server", self, "_connected_success")
	get_tree().connect("connection_failed", self, "_connected_failure")

	var client_scene = preload("res://shared/network/Client.tscn")
	get_tree().get_root().add_child(client_scene.instance())

func _connected_success():
	print("Connection successful")

func _connected_failure():
	print("Connection rejected")
	# TODO: More graceful handling here
	get_tree().quit()
