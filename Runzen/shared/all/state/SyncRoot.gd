extends Node

onready var clients = $Clients
onready var controllers = $Controllers

var _client_state_scene = preload("res://shared/all/state/ClientState.tscn")
var _controller_state_scene = preload("res://shared/all/state/ControllerState.tscn")

var _client_ids = {}
var _controller_ids = {}

func _ready():
	NetUtils.on_peer_disconnected(self, "_on_peer_disconnected")

func _on_peer_disconnected(id):
	remove_client(id)
	remove_controller(id)

# Server will be master (and should add before the client does)
func add_client(id: int):
	var client_state = _client_state_scene.instance()
	client_state.set_network_master(NetConstants.SERVER_ID)
	client_state.id = id
	client_state.name += str(id)
	clients.add_child(client_state)
	_client_ids[id] = client_state
	print("Added: ", client_state.get_path())

func remove_client(id: int):
	var found = find_client(id)
	if found != null:
		_client_ids.erase(id)
		found.queue_free()

func find_client(id: int) -> ClientState:
	return _client_ids.get(id)

# Controller will be master (and should add before the server does)
func add_controller(id: int):
	var controller_state = _controller_state_scene.instance()
	controller_state.set_network_master(id)
	controller_state.id = id
	controller_state.name += str(id)
	controllers.add_child(controller_state)
	_controller_ids[id] = controller_state
	print("Added: ", controller_state.get_path())

func remove_controller(id: int):
	var found = find_controller(id)
	if found != null:
		_controller_ids.erase(id)
		found.queue_free()

func find_controller(id: int) -> ControllerState:
	return _controller_ids.get(id)
