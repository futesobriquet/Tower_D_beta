function euclideanDistance(startCell, endCell)
	distance = math.sqrt((startCell.x-endCell.x)^2+(startCell.y-endCell.y)^2)
	return distance
end
function dumbEuclideanDistance(startCell, endCellX, endCellY)
	distance = math.sqrt((startCell.x-endCellX)^2+(startCell.y - endCellY)^2)
	return distance
end
function manhattanDistance(startCell, endCell)
	local dx = endCell.x - startCell.x
	local dy = endCell.y -  startCell.y
	return math.abs(dx) + math.abs(dy)
end
