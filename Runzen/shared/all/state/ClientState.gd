extends Node

class_name ClientState

const OFFSET_POS = "op"
const OFFSET_VEL = "ov"

var id = 0

onready var display_name: SyncDict = $DisplayName
onready var current_path: SyncDict = $CurrentPath
onready var current_offset: SyncDict = $CurrentOffset
onready var half_step: SyncDict = $HalfStep

func _ready():
	if NetUtils.is_master(self):
		if id == 0:
			push_error("ID must be set before adding ClientState")

		var restrict_to_ids = [id]
		display_name.restrict_to_ids = restrict_to_ids
		current_path.restrict_to_ids = restrict_to_ids
		current_offset.restrict_to_ids = restrict_to_ids
		half_step.restrict_to_ids = restrict_to_ids
