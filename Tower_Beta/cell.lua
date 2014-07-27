local class = require('lib.30log.30log')
Cell = class { x = 0, y = 0, occupied = false, prev = {}}

function Cell:__init(x, y, occupied, prev)
  self.x,self.y = x,y
  self.occupied = occupied
  self.prev = prev
end

function Cell:getEmptyNeighbors(grid)
	local emptyNeighbors = {}
	local x = self.x
	local y = self.y
	local north = grid[x+1][y]
	local south = grid[x - 1][y]
	local east = grid[x][y + 1]
	local west = grid[x][y - 1]
	if not north.occupied then
		table.insert(emptyNeighbors, north)
	end
	if not south.occupied then
		table.insert(emptyNeighbors, south)
	end
	if not east.occupied then
		table.insert(emptyNeighbors, east)
	end
	if not west.occupied then
		table.insert(emptyNeighbors, west)
	end
	return emptyNeighbors
end