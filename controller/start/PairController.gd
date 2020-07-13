extends Node

onready var _code_edit = $CodeEdit
onready var _status_label = $StatusLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	_code_edit.text = ""
	_code_edit.grab_focus()
	_status_label.text = ""

	get_tree().connect("connected_to_server", self, "_connected_success")
	get_tree().connect("connection_failed", self, "_connected_failure")

	var client_scene = preload("res://shared/network/Client.tscn")
	get_tree().get_root().add_child(client_scene.instance())

func _connected_success():
	_status_label.text = "Connection successful"

func _connected_failure():
	_status_label.text = "Connection rejected"


func _on_CodeEdit_text_changed(new_text):
	print(new_text)
