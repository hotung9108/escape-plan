extends Node

var pq = PriorityQueue.new()
var marker = {}
var g_score = {}
var endNode: Node2D = null
var path: Array = []
var pathIndex: int = 0
var nextNode: Node2D = null

func run(sNode: Node2D, eNode: Node2D) -> Vector2:
	# Already at destination
	if sNode == eNode:
		nextNode = eNode
		return Vector2.ZERO
	
	# Recalculate path if destination changed
	if eNode != endNode:
		endNode = eNode
		calculate_path(sNode, eNode)
		pathIndex = 0
	
	# Check if path exists
	if path.is_empty():
		nextNode = eNode
		return Vector2.ZERO
	
	# Move to next waypoint if reached current one
	if sNode == nextNode or nextNode == null:
		pathIndex += 1
	
	# Clamp pathIndex to stay within bounds
	pathIndex = mini(pathIndex, path.size() - 1)
	nextNode = path[pathIndex]
	
	# Return direction to next waypoint
	return get_parent().position.direction_to(nextNode.position)

func calculate_path(sNode: Node2D, eNode: Node2D):
	var actual_start = sNode
	
	# ✅ Check if start node is outside dynamic weight range
	if sNode.vertexWeight >= PathSystem.maxChildGeneration:
		print("Start node outside range, using DFS to find entry point")
		actual_start = find_nearest_weighted_node_bfs(sNode)
		
		if actual_start == null:
			print("No path to weighted nodes found!")
			path.clear()
			return
		
		print("Found entry point: %s (weight: %d)" % [actual_start.name, actual_start.vertexWeight])
	
	# Now run A* from the actual start
	calculate_astar_path(actual_start, eNode)

# ✅ DFS to find nearest node with vertex weight < maxChildGeneration
func find_nearest_weighted_node_dfs(start: Node2D) -> Node2D:
	var visited = {}
	var queue = [start]  # BFS queue for distance-based search
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
func find_nearest_weighted_node_bfs(start: Node2D) -> Node2D:
	var visited = {}
	var queue = [start]
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if visited.has(current):
			continue
		
		visited[current] = true
		
		# ✅ First weighted node we find is the closest (BFS property)
		if current.vertexWeight < PathSystem.maxChildGeneration:
			return current
		
		# Add neighbors to queue
		for neighbor in current.relativeNodes:
			if not visited.has(neighbor):
				queue.append(neighbor)
	
	return null  # No weighted nodes reachable

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
	nextNode = path[0] if path.size() > 0 else null
