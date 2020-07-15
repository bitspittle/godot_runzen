extends Node

onready var _code_edit = $CodeEdit
onready var _status_label = $StatusLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	_code_edit.text = ""
	_code_edit.grab_focus()
	_status_label.text = ""

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

func _on_CodeEdit_text_changed(new_text: String):
	if new_text.length() == 5:
		Handshake.request_pairing(new_text.to_lower())

func _pairing_succeeded():
	get_tree().change_scene("res://controller/screens/ControllerScreenMain.tscn")
