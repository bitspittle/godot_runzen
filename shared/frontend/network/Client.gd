# Client logic shared between game clients and controller clients
#
# To use, instantiate this and add it to the top level. Listen to
# normal network signals as before:
#
# get_tree().connect("connected_to_server", self, ...)
# get_tree().connect("connection_failed", self, ...)
# var client_scene = preload("res://shared/network/Client.tscn")
# get_tree().get_root().add_child(client_scene.instance())

extends Node

var _client: WebSocketClient = null

func _ready():
	NetUtils.on_server_rejected(self, "_on_server_rejected")

	var ip = CmdLineArgs.get_str_value("--ip")
	var port = CmdLineArgs.get_int_value("--port")

	if ip == "":
		if OsUtils.is_debug() && !OsUtils.is_mobile():
			ip = NetConstants.LOCALHOST
		else:
			ip = NetDefaults.SERVER_IP

	if port == 0:
		port = NetDefaults.PORT

	var prefix = "ws://"
	var url = prefix + ip + ":" + str(port)
	print("Connecting to: ", url, "...")
	_client = WebSocketClient.new()
	_client.connect_to_url(url, PoolStringArray(), true)
	get_tree().set_network_peer(_client)

func _process(delta):
	if _client == null: return

	var status = _client.get_connection_status()
	if status == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
	|| status == NetworkedMultiplayerPeer.CONNECTION_CONNECTING:
		_client.poll()

func _on_server_rejected():
	# TODO: Better handling
	get_tree().quit()
