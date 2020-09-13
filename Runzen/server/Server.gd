extends Node

var _server: WebSocketServer = null

func _ready():
	var port = CmdLineArgs.get_int_value("--port")
	if port == 0:
		port = NetDefaults.PORT

	print("IPs: ", IP.get_local_addresses())
	print("Server will listen on port: ", port)

	_server = WebSocketServer.new()
	_server.listen(port, PoolStringArray(), true)
	get_tree().set_network_peer(_server)
	print("Server created and listening for connections")

	Handshake.prepare_server()
