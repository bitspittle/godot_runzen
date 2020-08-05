# A list of services provided between the server and clients and controllers
extends Node

const _CHAR_CODE_A = 97

signal received_pairing_code(code)
signal pairing_succeeded()
signal pairing_failed()

master var codes = {} # Map of codes to client IDs
master var controller_to_client = {} # Map of controller IDs to client IDs

master func prepare_server():
	randomize()
	NetUtils.on_peer_disconnected(self, "_peer_disconnected")

master func _peer_disconnected(id):
	print("Peer disconnected: ", id)
	for code in codes.keys():
		if codes[code] == id:
			print("Erasing unused code after client disconnected: ", code)
			codes.erase(code)
			return

# Client <-> Server

puppet func request_pairing_code():
	if !NetUtils.is_server(self):
		rpc_id(NetConstants.SERVER_ID, "_request_pairing_code", NetUtils.get_unique_id(self))

master func _request_pairing_code(from_id: int) -> void:
	var code = 0
	for i in range(6):
		var digit = 0
		if i == 0:
			digit = 1 + randi() % 9
		else:
			digit = randi() % 10

		code *= 10
		code += digit

	var code_str = str(code)

	print("Generated code \"", code_str, "\" for id: ", from_id)
	codes[code_str] = from_id
	rpc_id(from_id, "_receive_pairing_code", code_str)

puppet func _receive_pairing_code(code: String) -> void:
	emit_signal("received_pairing_code", code)

# Controller <-> Server

puppet func request_pairing(code: String) -> void:
	if !NetUtils.is_server(self):
		rpc_id(NetConstants.SERVER_ID, "_request_pairing", NetUtils.get_unique_id(self), code)

master func _request_pairing(from_id: int, code: String):
	var succeeded = false
	if codes.has(code):
		var to_id = codes[code]
		controller_to_client[from_id] = to_id
		print("Consuming code: ", code)
		codes.erase(code)

		SyncRoot.add_controller(from_id)
		SyncRoot.add_client(to_id)
		for id in [from_id, to_id]:
			rpc_id(id, "_pairing_succeeded")

	else:
		rpc_id(from_id, "_pairing_failed")

puppet func _pairing_succeeded():
	emit_signal("pairing_succeeded")

puppet func _pairing_failed():
	emit_signal("pairing_failed")

master func create_controller_state(id: int):
	SyncRoot.create_controller(id)
