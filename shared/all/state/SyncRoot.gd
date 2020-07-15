extends Node

onready var clients = $Clients
onready var controllers = $Controllers

var _client_state_scene = preload("res://shared/all/state/ClientState.tscn")
var _controller_state_scene = preload("res://shared/all/state/ControllerState.tscn")

func _ready():
	NetUtils.on_peer_disconnected(self, "_on_peer_disconnected")

func _on_peer_disconnected(id):
	remove_client(id)
	remove_controller(id)

# Server will be master (and should add before the client does)
func add_client(id: int):
	var client_state = _client_state_scene.instance()
	client_state.set_network_master(NetConstants.SERVER_ID)
	client_state.name += str(id)
	clients.add_child(client_state)

func remove_client(id: int):
	var id_str = str(id)
	for client_state in clients.get_children():
		if client_state.name.ends_with(id_str):
			client_state.queue_free()
			return

# Controller will be master (and should add before the server does)
func add_controller(id: int):
	var controller_state = _controller_state_scene.instance()
	controller_state.set_network_master(id)
	controller_state.name += str(id)
	controllers.add_child(controller_state)

func remove_controller(id: int):
	var id_str = str(id)
	for controller_state in controllers.get_children():
		if controller_state.name.ends_with(id_str):
			controller_state.queue_free()
			return
