extends Node

class_name ControllerState

var id = 0

onready var step: SyncDict = $Step

func _ready():
	if id == 0:
		push_error("ID must be set before adding ControllerState")

	if NetUtils.is_master(self):
		step.restrict_to_ids = [1]


func _on_Step_values_changed():
	var client_id = Handshake.controller_to_client[id]
	SyncRoot.find_client(client_id).step.value = step.value
