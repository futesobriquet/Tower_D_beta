    Cell = {
	x = -1, 
	y= -1,
	occupied = false
	}
function love.load()
	player = {
        grid_x = 256,
        grid_y = 256,
        act_x = 200,
        act_y = 200,
        speed = 10
    }
	

	mapSize = {
		x = 13,
		y = 13
	}
	
	walls = {
        { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
        { 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1 },
        { 1, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1 },
        { 1, 1, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1 },
        { 1, 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1 },
        { 1, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1 },
        { 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1 },
        { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
    }
	
	map = walls
		
	for x=1, mapSize.x do
        for y=1, mapSize.y do
			if walls[x][y] == 1 then
				map[x][y] = Cell:new(nil, x, y, true)
			else
				map[x][y] = Cell:new(nil, x, y, true)
            end
        end
    end

	--path = pathPlan(player.grid_x, player.grid_y, goal, map)
end

function love.update(dt)
	dir = math.random(4)
	move(player, dir, map)
    player.act_y = player.act_y - ((player.act_y - player.grid_y) * player.speed * dt)
    player.act_x = player.act_x - ((player.act_x - player.grid_x) * player.speed * dt)
end

function love.draw()
    love.graphics.rectangle("fill", player.act_x, player.act_y, 32, 32)
    for x=1, #map do
        for y=1, #map[y] do
            if map[x][y] == 1 then
                love.graphics.rectangle("line", x * 32, y * 32, 32, 32)
            end
        end
    end
end

function move(player, dir, map)
	if dir == 1 then --up
        if testMap(player.grid_x, player.grid_y , 0, -1, map) then
            player.grid_y = player.grid_y - 32
        end
    elseif dir == 2 then --down
        if testMap(player.grid_x, player.grid_y , 0, 1, map) then
            player.grid_y = player.grid_y + 32
        end
    elseif dir == 3 then --lefT?
        if testMap(player.grid_x, player.grid_y , -1, 0,map) then
            player.grid_x = player.grid_x - 32
        end
    elseif dir == 4 then -- right?
        if testMap(player.grid_x, player.grid_y, 1, 0,map) then
            player.grid_x = player.grid_x + 32
        end
    end
end

function testMap(curX, curY, goalX, goalY, map)
    nextCell = map[(curX) + goalX][(curY) + goalY]
	if nextCell.occupied == true then
        return false
    end
    return true
end

function planPath(parent, goal, grid)
	local path = {parent}
	local leastDistance = nil
	while parent.x ~= goal.x and parent.y ~= goal.y do
		validMoves = parent:getEmptyNeighbors(grid)
		for i,thisCell in pairs(validMoves) do
			distance = thisCell:getDistance(goal)
			if leastDistance then
				if distance < leastDistance then --could be a tie. on second pass handle this
					leastDistance = distance
					child = thisCell
				end
			else
				leastDistance = distance
				child = thisCell
			end
		end
	path.insert(child)
	parent = child
	end
	return path
end

function Cell:new(x,y,occupied)
	o = o or {} --i guess how you class in lua weee
	setmetatable(o, self)
	self.__index = self
	self.x = x
	self.y = y
	self.occupied = occupied or false
	return o
end
function Cell:getEmptyNeighbors(grid)
	emptyNeighbors = {}
	x = self.x
	y = self.y
	north = grid[x+1][y]
	south = grid[x - 1][y]
	east = grid[x][y + 1]
	west = grid[x][y - 1]
	if not north.occupied then
		emptyNeighbors.insert(north)
	end
	if not south.occupied then
		emptyNeighbors.insert(south)
	end
	if not east.occupied then
		emptyNeighbors.insert(east)
	end
	if not west.occupied then
		emptyNeighbors.insert(west)
	end
	return emptyNeighbors
end
function Cell:getDistance(goal)
	dx = self.x - goal.x 
	dy = self.y - goal.y
	distance = math.abs(dx) + math.abs(dy)
	return distance
end