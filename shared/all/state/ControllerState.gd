extends Node

class_name ControllerState

var id = 0

onready var steps_per_sec: SyncDict = $StepsPerSec

func _ready():
	if id == 0:
		push_error("ID must be set before adding ControllerState")

	if NetUtils.is_master(self):
		steps_per_sec.restrict_to_ids = [1]

func _on_StepsPerSec_values_changed():
	var client_id = Handshake.controller_to_client[id]
	SyncRoot.find_client(client_id).steps_per_sec.value = steps_per_sec.value
