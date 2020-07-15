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
	var code = ""
	for i in range(5):
		var letter_or_digit = randi() % 36
		if letter_or_digit < 10:
			var digit = letter_or_digit
			code += str(digit)
		else:
			var letter = letter_or_digit - 10
			code += char(_CHAR_CODE_A + letter)

	print("Generated code \"", code, "\" for id: ", from_id)
	codes[code] = from_id
	rpc_id(from_id, "_receive_pairing_code", code)

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
