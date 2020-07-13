extends Node

var _server: WebSocketServer = null

func _ready():
	var port = CmdLineArgs.get_int_value("--port")
	if port == 0:
		port = NetDefaults.PORT

	print("Server will listen on port: ", port)

#	get_tree().connect("network_peer_connected", self, "_peer_connected")
#	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected")

	_server = WebSocketServer.new()
	_server.listen(port, PoolStringArray(), true)
	get_tree().set_network_peer(_server)
	print("Server created and listening for connections")

