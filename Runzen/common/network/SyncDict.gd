extends Node

# A dictionary that gets synced regularly across a network connection

# Prerequisite:
# * Create a SyncDict in your scene.
# * Create the master copy before the puppet copy
#
# # SomeScene.gd
#
# onready var _data = $SyncedData
#
# func _ready():
#	if !is_network_master():
# 		# values_changed only triggered on puppet anyway, so avoid
#		# unecessary connecting
# 		_data.connect("values_changed", self, "_on_data_updated")
#
# func update_pos():
#	if is_network_master():
#		# Setting data on puppets is harmless but best avoided
#		# to limit places the data gets set, making debugging
#		# easier.
# 		_data.values["pos"] = position
#
# func _on_data_updated():
#	 position = _data.values["pos"]

class_name SyncDict

signal values_changed

export var reliable = false
export var throttle_msec = 30 # Ignored if reliable
var values = {}
# Convenient shorthand for syncdicts that only contain a single value
var value = null setget _set_value, _get_value

var _timestamp = 0
var _last_values = {}
var _remaining_msec = 0.0

# If set, only send updates to specific targets; else, everyone
export var restrict_to_ids = []

func _set_value(v):
	self.values["_"] = v

func _get_value():
	if self.values.has("_"):
		return self.values["_"]
	else:
		print("Trying to get general value, not set for SyncDict: ", get_path())
		return null

func _ready():
	if NetUtils.is_puppet(self):
		rpc_id(NetUtils.get_master_id(self), "_initial_request_from", NetUtils.get_unique_id(self))

master func _initial_request_from(id):
	rpc_id(id, "_receive", _create_payload())

func _process(delta):
	if values.empty() || !NetUtils.is_master(self):
		return

	if reliable:
		if _last_values.hash() != values.hash():
			_last_values = values.duplicate()
			if restrict_to_ids.empty():
				rpc("_receive", _create_payload())
			else:
				for id in restrict_to_ids:
					rpc_id(id, "_receive", _create_payload())
	else:
		_remaining_msec -= delta
		if _remaining_msec <= 0:
			_remaining_msec = throttle_msec / 1000.0
			if _last_values.hash() != values.hash():
				_last_values = values.duplicate()
				if restrict_to_ids.empty():
					rpc_unreliable("_receive", _create_payload())
				else:
					for id in restrict_to_ids:
						rpc_unreliable_id(id, "_receive", _create_payload())

func _create_payload():
	return [OS.get_ticks_msec(), values]

puppet func _receive(payload) -> void:
	var other_timestamp = payload[0]
	var other_values = payload[1]
	if other_timestamp > _timestamp:
		_timestamp = other_timestamp
		values = other_values
		if _last_values.hash() != values.hash():
			_last_values = values.duplicate()
			emit_signal("values_changed")
