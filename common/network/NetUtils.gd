class_name NetUtils

static func is_networked(node: Node) -> bool:
	return node.get_tree().network_peer != null

static func is_local(node) -> bool:
	return !is_networked(node)

static func is_master_or_local(node: Node):
	return is_local(node) || node.is_network_master()

static func is_master(node: Node) -> bool:
	return is_networked(node) && node.is_network_master()

static func is_puppet(node: Node) -> bool:
	return is_networked(node) && !node.is_network_master()

static func is_server(node: Node) -> bool:
	return is_networked(node) && node.get_tree().is_network_server()

static func is_client(node: Node) -> bool:
	return is_networked(node) && !node.get_tree().is_network_server()

static func get_unique_id(node: Node) -> int:
	if is_networked(node):
		return node.get_tree().get_network_unique_id()
	else:
		return NetConstants.UNNETWORKED_ID

static func get_master_id(node: Node) -> int:
	if is_networked(node):
		return node.get_network_master()
	else:
		return NetConstants.UNNETWORKED_ID


static func on_server_connected(node: Node, callback: String) -> void:
	node.get_tree().connect("connected_to_server", node, callback)

static func on_server_connection_failed(node: Node, callback: String) -> void:
	node.get_tree().connect("connection_failed", node, callback)

static func on_peer_connected(node: Node, callback: String) -> void:
	node.get_tree().connect("network_peer_connected", node, callback)

static func on_peer_disconnected(node: Node, callback: String) -> void:
	node.get_tree().connect("network_peer_disconnected", node, callback)
