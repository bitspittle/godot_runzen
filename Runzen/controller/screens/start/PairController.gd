extends Node

onready var _code = $PairingCodeLabel
onready var _status_label = $StatusLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	_code.text = ""
	_status_label.text = ""

	for child in $KeyPad.get_children():
		var button: Button = child
		button.connect("pressed", self, "_on_KeyPadButton_pressed", [button])

	NetUtils.on_server_connected(self, "_connected_success")
	NetUtils.on_server_rejected(self, "_connected_failure")

	Handshake.connect("pairing_succeeded", self, "_pairing_succeeded")

	var client_scene = preload("res://shared/frontend/network/Client.tscn")
	get_tree().get_root().add_child(client_scene.instance())

func _connected_success():
	_status_label.text = "Connection successful"
	SyncRoot.add_controller(NetUtils.get_unique_id(self))

func _connected_failure():
	_status_label.text = "Connection rejected"

func _pairing_succeeded():
	get_tree().change_scene("res://controller/screens/ControllerMain.tscn")

func _on_KeyPadButton_pressed(sender: Button):
	if sender.text == "X":
		if !_code.text.empty():
			_code.text = _code.text.substr(0, _code.text.length() - 1)
			
	else:
		if _code.text.length() == 6:
			_code.text = _code.text.substr(0, _code.text.length() - 1)

		_code.text += sender.text
		if _code.text.length() == 6:
			Handshake.request_pairing(_code.text)
