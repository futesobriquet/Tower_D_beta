    Cell = {
	x = nil, 
	y= nil,
	occupied = false,
	visited = false,
	prev = {}
	}
function love.load()
	pathChange = false
	
	player = {
        grid_x = 64,
        grid_y = 64,
        act_x = 64,
        act_y = 64,
        speed = 80
    }
	

	mapSize = {
		x = 13,
		y = 13
	}
	
	initialWalls = {
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
	
	map = {}
	for i=1, mapSize.x do
		map[i] = {}
		for j=1, mapSize.y do
			map[i][j] = nil
		end
	end
	
		
	for x=1, mapSize.x do
        for y=1, mapSize.y do
			if initialWalls[x][y] == 1 then
				map[x][y] = Cell:new{x = x, y = y, occupied = true, visited = false, prev = {}}
			else
				map[x][y] = Cell:new{x = x, y = y, occupied = false, visited = false, prev = {}}
            end
        end
    end

	path = ASTARBITCHES(map[player.grid_x/32][player.grid_y/32], map[2][12], map)
	nextNode = path[1]
	pathIndex = 1
	printPath(path)
end

function love.update(dt)
	--print('act x: ' .. player.act_x / 32 .. ', act y: ' .. player.act_y / 32)
	
	if pathChange == true then
		--Why no A*bitch?
		-- path = ASTARBITCHES(map[player.grid_x/32][player.grid_y/32], map[2][12], map)
		-- nextNode = path[1]
		-- pathIndex = 1
		pathChange = false
		print(pathChange)
	end
	
	if math.abs((player.act_x / 32) - nextNode.x) < 0.02 and math.abs((player.act_y / 32) - nextNode.y) < 0.02 then
		pathIndex = pathIndex + 1
		if pathIndex <= #path then
			nextNode = path[pathIndex]
		end
	end
	local dx = (nextNode.x - player.act_x/32)
	if math.abs(dx) < 0.02 then
		dx = 0
	end
	if dx ~= 0 then
		dx =  dx / (math.abs((nextNode.x - player.act_x/32)))
	end
	
	local dy = (nextNode.y - player.act_y/32)
	if math.abs(dy) < 0.02 then
		dy = 0
	end
	if dy ~= 0 then
		 dy = dy / (math.abs((nextNode.y - player.act_y/32)))
	end
	player.act_x = player.act_x + dx * player.speed * dt
	player.act_y = player.act_y + dy * player.speed * dt
end

function love.draw()
    love.graphics.rectangle("fill", player.act_x, player.act_y, 32, 32)
    for x=1, mapSize.x do
        for y=1, mapSize.y do
            if map[x][y].occupied == true then
				love.graphics.rectangle("line", x * 32, y * 32, 32, 32)
            end
        end
    end
end

function love.mousereleased(x, y, button)
   if button == "l" then
		mapX = math.floor(x/32) 
		mapY = math.floor(y/32) 
		print('x: ' .. mapX  ..' '.. 'y: ' .. mapY)
		if mapX <= 13  and mapY <=13 then --bad bad hard coding weee
			local clickedCell = map[mapX][mapY] 
			clickedCell.occupied = not clickedCell.occupied
			pathChange = true
		end
   end
end

--Teh Brian code, feel free to delete although it is a working implementation of A* search
function ASTARBITCHES(start, goal, grid)
	local toSearch = {}
	toSearch[start] = true
	local gScores = {}
	gScores[start] = 0
	local fScores = {}
	fScores[start] = manhattanDistance(start, goal)
	while next(toSearch) ~= nil do
		local cur = findMinInSet(fScores)
		if cur.x == goal.x and cur.y == goal.y then
			return buildPath(cur)
		end
		toSearch[cur] = nil
		cur.visited = true
		local neighbors = cur:getEmptyNeighbors(grid)
		for i=1,#neighbors do
			if neighbors[i].visited == false then
				local tempScore = gScores[cur] + 1
				if toSearch[neighbors[i]] == nil or tempScore < gScores[neighbors[i]] then
					neighbors[i].prev = cur
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
end

function manhattanDistance(startCell, endCell)
	local dx = endCell.x - startCell.x
	local dy = endCell.y -  startCell.y
	return math.abs(dx) + math.abs(dy)
end

function findMinInSet(set)
	local minimum = 100000
	local toReturn = nil
	for key,value in pairs(set) do
		if value < minimum and key.visited == false then
			minimum = value
			toReturn = key
		end
	end
	return toReturn
end

function buildPath(node)
	local path = {}
	local curNode = node
	while curNode ~= nil do
		table.insert(path, curNode)
		curNode = curNode.prev
	end
	local size = #path
	local newPath = {}
	
	for i,v in ipairs(path) do
		newPath[size-i] = v
	end
	return newPath
end

function printPath(path)
	local s = '['
	for i=1,#path do
		s = s .. '[' .. path[i].x .. ', ' .. path[i].y ..']'
	end
	s = s .. ']'
	print(s)
end
--end teh Brian code

function Cell:new(o)
	o = o or{} --i guess how you class in lua weee
	setmetatable(o, self)
	self.__index = self
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
-- function Cell:getDistance(goal)
	-- dx = self.x - goal.x 
	-- dy = self.y - goal.y
	-- distance = math.abs(dx) + math.abs(dy)
	-- return distance
-- end