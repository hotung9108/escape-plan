class_name PriorityQueue

var _nodes: Dictionary = {}  # node_id -> {priority, node_data}
var _sorted_keys: Array = []

func push(node_id, priority: float, node_data):
	_nodes[node_id] = {"priority": priority, "data": node_data}
	
	# Insert in sorted position
	var insert_pos = _sorted_keys.bsearch_custom(priority, func(a, b): 
		return _nodes[a].priority < b
	)
	_sorted_keys.insert(insert_pos, node_id)

func pop():
	if _sorted_keys.is_empty():
		return null
	
	var node_id = _sorted_keys.pop_front()
	var result = _nodes[node_id].data
	_nodes.erase(node_id)
	
	return result

func update_priority(node_id, new_priority: float):
	if not _nodes.has(node_id):
		return
	
	# Remove old position
	_sorted_keys.erase(node_id)
	
	# Update priority
	_nodes[node_id].priority = new_priority
	
	# Re-insert
	var insert_pos = _sorted_keys.bsearch_custom(new_priority, func(a, b):
		return _nodes[a].priority < b
	)
	_sorted_keys.insert(insert_pos, node_id)

func has(node_id) -> bool:
	return _nodes.has(node_id)

func is_empty() -> bool:
	return _sorted_keys.is_empty()

func clear():
	_nodes.clear()
	_sorted_keys.clear()

func get_priority(node_id) -> float:
	if not _nodes.has(node_id):
		return INF  # Or return -1, or push_error
	return _nodes[node_id].priority
