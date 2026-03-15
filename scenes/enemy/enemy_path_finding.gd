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
		pathIndex = 0  # Reset index on new path
	
	# Check if path exists
	if path.is_empty():
		nextNode = eNode  # No path found, aim for end node
		return Vector2.ZERO
	
	# Move to next waypoint if reached current one
	if sNode == nextNode or nextNode == null:
		pathIndex += 1
	
	# ✅ Clamp pathIndex to stay within bounds
	pathIndex = mini(pathIndex, path.size() - 1)
	nextNode = path[pathIndex]
	
	# Return direction to next waypoint
	return get_parent().position.direction_to(nextNode.position)

func calculate_path(sNode: Node2D, eNode: Node2D):
	pq.clear()
	marker.clear()
	g_score.clear()
	path.clear()
	
	# Track which nodes we've ALREADY PROCESSED (closed set)
	var closed_set = {}
	
	# Initialize start
	g_score[sNode] = 0
	var h = sNode.vertexWeight
	pq.push(sNode, h, sNode)
	
	while not pq.is_empty():
		var currentNode = pq.pop()
		
		if currentNode == null:
			break
		
		# ✅ CRITICAL: Skip if already processed
		if closed_set.has(currentNode):
			continue
		
		# Mark as processed
		closed_set[currentNode] = true
		
		# Found goal
		if currentNode == eNode:
			break
		
		# Check all neighbors
		for i in range(currentNode.relativeNodes.size()):
			var neighbor = currentNode.relativeNodes[i]
			
			# ✅ Skip if already processed (won't go back)
			if closed_set.has(neighbor):
				continue
			
			# Calculate new g-score
			var edge_cost = currentNode.relativeNodesDistance[i]
			var tentative_g = g_score[currentNode] + edge_cost
			
			# ✅ Only update if this is a better path
			if not g_score.has(neighbor) or tentative_g < g_score[neighbor]:
				# Found better path to this neighbor
				g_score[neighbor] = tentative_g
				marker[neighbor] = currentNode
				
				# Calculate f-score
				var h_neighbor = neighbor.vertexWeight
				var f = tentative_g + h_neighbor
				
				# Update or add to priority queue
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
