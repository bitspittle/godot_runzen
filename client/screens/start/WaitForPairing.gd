extends Node

onready var _pairing_code_label = $PairingCodeLabel

func _ready():
	_pairing_code_label.text = ""

	get_tree().connect("connected_to_server", self, "_connected_success")
	get_tree().connect("connection_failed", self, "_connected_failure")
	Handshake.connect("received_pairing_code", self, "_received_pairing_code")
	Handshake.connect("pairing_succeeded", self, "_pairing_succeeded")

	var client_scene = preload("res://shared/frontend/network/Client.tscn")
	get_tree().get_root().add_child(client_scene.instance())

func _connected_success():
	print("Connection successful")
	Handshake.request_pairing_code()

func _connected_failure():
	print("Connection rejected")
	# TODO: More graceful handling here
	get_tree().quit()

func _received_pairing_code(code: String) -> void:
	_pairing_code_label.text = code

func _pairing_succeeded() -> void:
	get_tree().change_scene("res://client/world/Island.tscn")
