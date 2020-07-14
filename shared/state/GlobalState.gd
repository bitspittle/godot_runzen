extends Node

onready var handshake: Handshake = $Handshake
onready var clients = $Clients
onready var controllers = $Controllers

func _ready():
	get_tree().connect("connected_to_server", self, "_connected_success")

func _connected_success():
	set_network_master(NetConstants.SERVER_ID)
	print("GlobalState master mode set to server")
