# A list of services provided between the server and clients and controllers
extends Node

const _CHAR_CODE_A = 97

signal received_pairing_code(code)

master var codes = {}

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

	codes[from_id] = code
	rpc_id(from_id, "_receive_pairing_code", code)

puppet func _receive_pairing_code(code: String) -> void:
	emit_signal("received_pairing_code", code)


