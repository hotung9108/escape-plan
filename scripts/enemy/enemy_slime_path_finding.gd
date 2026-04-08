extends Node2D

var pq = PriorityQueue.new()
var marker = {}
var g_score = {}
var endNode: Node2D = null
var path: Array = []
var pathIndex: int = 0
var nextNode: Node2D = null
@export var currentNode: Node2D
@export var pathSystem: Node2D

func setup():
	currentNode = pathSystem.find_object_nearest_node(self )
	nextNode = currentNode

func change_room(room: Node2D):
	pathSystem = room
	currentNode = null
	nextNode = null
	path.clear()
	endNode = null

func run(target: Node2D) -> Vector2:
	if target == null or pathSystem == null:
		return Vector2.ZERO
	
	var pos = get_parent().position
	
	if currentNode == null:
		currentNode = pathSystem.find_object_nearest_node(get_parent())
		nextNode = currentNode
		calculate_path(currentNode, target)
	
	if target != endNode:
		endNode = target
		calculate_path(currentNode, target)
		pathIndex = 0
		
		# Set nextNode to first node in path (or target if no path)
		if not path.is_empty():
			nextNode = path[0]
		else:
			nextNode = target
	
	# ✅ Check if at currentNode
	var dist_to_current = pos.distance_to(currentNode.position)
	
	if dist_to_current > 3:
		# ✅ Not at currentNode yet - move to it first
		return pos.direction_to(currentNode.position)
	
	# ✅ At currentNode - check if we need to advance
	if pathIndex < path.size() - 1:
		# ✅ Not at last node - advance to next
		pathIndex += 1
		nextNode = path[pathIndex]
		currentNode = nextNode
		
		# Return direction to new currentNode
		return pos.direction_to(currentNode.position)
	else:
		if path.size() > 0:
			var last_node = path[path.size() - 1]
			currentNode = last_node
			nextNode = last_node # ✅ Stay at last node
			
			# Check if close enough to last node
			if pos.distance_to(last_node.position) <= 3:
				return Vector2.ZERO
			else:
				return pos.direction_to(last_node.position)
	
	return Vector2.ZERO

func calculate_path(sNode: Node2D, eNode: Node2D):
	if sNode == null or eNode == null:
		return
	
	var prefix_path = []
	var actual_start = sNode
	
	# ✅ Check if start node is outside dynamic weight range
	if sNode.vertexWeight >= PathSystem.maxChildGeneration:
		print("Start node outside range, using BFS to find entry point")
		prefix_path = find_nearest_weighted_node_bfs(sNode)
		
		if prefix_path.is_empty():
			print("No path to weighted nodes found!")
			path.clear()
			return
		
		actual_start = prefix_path[-1]
		print("Found entry point: %s (weight: %d)" % [actual_start.name, actual_start.vertexWeight])
	
	# Now run A* from the actual start
	calculate_astar_path(actual_start, eNode)
	
	# If we have a prefix, merge it (skipping duplicate entry point)
	if not prefix_path.is_empty():
		prefix_path.pop_back()
		prefix_path.append_array(path)
		path = prefix_path

# ✅ DFS to find nearest node with vertex weight < maxChildGeneration
func find_nearest_weighted_node_dfs(start: Node2D) -> Node2D:
	var visited = {}
	var queue = [start] # BFS queue for distance-based search
	var best_node: Node2D = null
	var best_distance: float = INF
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		# Skip if already visited
		if visited.has(current):
			continue
		
		visited[current] = true
		
		# ✅ Found a node in the weighted range!
		if current.vertexWeight < PathSystem.maxChildGeneration:
			var distance = start.position.distance_squared_to(current.position)
			
			# Keep track of closest weighted node
			if distance < best_distance:
				best_distance = distance
				best_node = current
		
		# Add neighbors to queue
		for neighbor in current.relativeNodes:
			if not visited.has(neighbor):
				queue.append(neighbor)
	
	return best_node

# BFS guarantees shortest path to weighted zone
func find_nearest_weighted_node_bfs(start: Node2D) -> Array:
	var visited = {}
	var parent_map = {}
	var queue = [start]
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if visited.has(current):
			continue
		
		visited[current] = true
		
		# ✅ First weighted node we find is the closest (BFS property)
		if current.vertexWeight < PathSystem.maxChildGeneration:
			var p = []
			var temp = current
			while temp != null:
				p.push_front(temp)
				temp = parent_map.get(temp, null)
			return p
		
		# Add neighbors to queue
		for neighbor in current.relativeNodes:
			if not visited.has(neighbor):
				if not parent_map.has(neighbor):
					parent_map[neighbor] = current
				queue.append(neighbor)
	
	return [] # No weighted nodes reachable

# Original A* implementation
func calculate_astar_path(sNode: Node2D, eNode: Node2D):
	pq.clear()
	marker.clear()
	g_score.clear()
	path.clear()
	
	var closed_set = {}
	
	# Initialize start
	g_score[sNode] = 0
	var h = sNode.vertexWeight
	pq.push(sNode, h, sNode)
	
	while not pq.is_empty():
		var currentNode = pq.pop()
		
		if currentNode == null:
			break
		
		if closed_set.has(currentNode):
			continue
		
		closed_set[currentNode] = true
		
		if currentNode == eNode:
			break
		
		for i in range(currentNode.relativeNodes.size()):
			var neighbor = currentNode.relativeNodes[i]
			
			if closed_set.has(neighbor):
				continue
			
			var edge_cost = currentNode.relativeNodesDistance[i]
			var tentative_g = g_score[currentNode] + edge_cost
			
			if not g_score.has(neighbor) or tentative_g < g_score[neighbor]:
				g_score[neighbor] = tentative_g
				marker[neighbor] = currentNode
				
				var h_neighbor = neighbor.vertexWeight
				var f = tentative_g + h_neighbor
				
				if pq.has(neighbor):
					pq.update_priority(neighbor, f)
				else:
					pq.push(neighbor, f, neighbor)
	
	# Reconstruct path
	path.clear()
	var temp = eNode
	while temp != null:
		path.push_front(temp)
		temp = marker.get(temp, null)
	
	pathIndex = 0

func force_recalculate(target: Node2D):
	if target == null or pathSystem == null:
		return
	
	# Find nearest node from current position
	currentNode = pathSystem.find_object_nearest_node(get_parent())
	nextNode = currentNode
	endNode = target
	
	# Calculate new path from current position
	calculate_path(currentNode, target)
	pathIndex = 0
	
	# Set nextNode to first node in path
	if not path.is_empty():
		nextNode = path[0]
	else:
		nextNode = target

func patrol() -> Vector2:
	if pathSystem == null:
		return Vector2.ZERO
	
	var pos = get_parent().position
	
	# Initial setup if nothing is targeted
	if endNode == null:
		var start_node = pathSystem.find_object_nearest_node(get_parent())
		if start_node:
			return run(start_node)
		return Vector2.ZERO
	
	# Check if reached target
	var dist_to_target = pos.distance_to(endNode.position)
	if dist_to_target <= 5.0:
		var connections = endNode.relativeNodes
		if connections.size() > 0:
			var valid_nodes = []
			var current_parent = endNode.get_parent()
			for node in connections:
				if node.get_parent() == current_parent:
					valid_nodes.append(node)
			
			if valid_nodes.size() > 0:
				var next_target = valid_nodes[randi() % valid_nodes.size()]
				return run(next_target)
				
	return run(endNode)
