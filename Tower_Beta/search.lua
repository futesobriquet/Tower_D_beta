local manhattanDistance, findMinInSet, buildPath 
search = {
	--param 1 : Cell, param 2 : Cell
	findShortestPath = function (start, goal, grid)
		local toSearch = {}
		toSearch[start] = true
		local gScores = {}
		gScores[start] = 0
		local fScores = {}
		fScores[start] = manhattanDistance(start, goal)
		local visited = {}
		local previous = {}
		while next(toSearch) ~= nil do
			local cur = findMinInSet(fScores, visited)
			if cur.x == goal.x and cur.y == goal.y then
				return buildPath(cur, previous)
			end
			toSearch[cur] = nil
			visited[cur] = true
			local neighbors = cur:getEmptyNeighbors(grid)
			for i=1,#neighbors do
				if visited[neighbors[i]] == nil then
					local tempScore = gScores[cur] + 1
					if toSearch[neighbors[i]] == nil or tempScore < gScores[neighbors[i]] then
						previous[neighbors[i]] = cur;
						gScores[neighbors[i]] = tempScore
						fScores[neighbors[i]] = tempScore + manhattanDistance(neighbors[i], goal)
						if toSearch[neighbors[i]] == nil then
							toSearch[neighbors[i]] = true
						end
					end
				end
			end			
		end
		return {}
	end,
	
	printPath = function (path)
		local s = '['
		for i=1,#path do
			s = s .. '[' .. path[i].x .. ', ' .. path[i].y ..']'
		end
		s = s .. ']'
		print(s)
	end
}

function manhattanDistance(startCell, endCell)
	local dx = endCell.x - startCell.x
	local dy = endCell.y -  startCell.y
	return math.abs(dx) + math.abs(dy)
end

function findMinInSet(set, visited)
	local minimum = 100000
	local toReturn = nil
	for key,value in pairs(set) do
		if value < minimum and visited[key] == nil then
			minimum = value
			toReturn = key
		end
	end
	return toReturn
end

function buildPath(node, previous)
	local path = {}
	local curNode = node
	while curNode ~= nil do
		table.insert(path, curNode)
		curNode = previous[curNode]
	end
	local size = #path
	local newPath = {}
	
	for i,v in ipairs(path) do
		newPath[size-i] = v
	end
	return newPath
end

return search