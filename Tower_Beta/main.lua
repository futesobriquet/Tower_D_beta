local class = require('lib.30log.30log')
require('character')
require('cell')
require('constants')
require('utils.timer')

function love.load()
	players = {}
	numPlayers = 1
	for i=1,numPlayers do
		players[i] = Character:new(cellSize * 2, cellSize * 2, 50 + (i - 1))
		players[i]:setImage("img/Arrow.png")
	end
	mapSize = { x = 13, y = 13 }
	
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
	
	map = {}
	for i=1, mapSize.x do
		map[i] = {}
		for j=1, mapSize.y do
			map[i][j] = nil
		end
	end
	
		
	for x=1, mapSize.x do
        for y=1, mapSize.y do
			if walls[x][y] == 1 then
				map[x][y] = Cell:new(x, y, true, {})
			else
				map[x][y] = Cell:new(x, y, false, {})
            end
        end
    end
	timer = Timer:new(0.3, addCharacter, nil)
	timer:start()
end

function addCharacter()
	local p = Character:new(cellSize * 2, cellSize * 2,50 + (200 * math.random()))
	p:setImage("img/Arrow.png")
	table.insert(players, p)
	numPlayers = numPlayers + 1
	p:moveTo(map[12][12], map)
end

function love.update(dt)
	--timer:update(dt)
	for i=1,numPlayers do
		players[i]:moveAlongPath(dt, map)
	end		
end

function love.draw()
	for i=1,numPlayers do
		local player = players[i]
		local width = player:getImage():getWidth()
		local height = player:getImage():getHeight()
		love.graphics.draw(player:getImage(), player.x + cellSize/2, player.y + cellSize/2, player:getOrientation(), 1, 1, width / 2, height / 2)
    end
	for x=1, mapSize.x do
        for y=1, mapSize.y do
			cell = map[x][y]
            if cell.occupied == true then
				love.graphics.rectangle("line", x * cellSize, y * cellSize, cellSize, cellSize)
			end
        end
    end
end

function love.mousereleased(x, y, button)
	if button == 'l' then
		gridX = math.floor(x/cellSize)
		gridY = math.floor(y/cellSize)
		clickedCell = map[gridX][gridY]
		clickedCell.occupied = not clickedCell.occupied
	end
	if button == 'r' then
		gridX = math.floor(x/cellSize)
		gridY = math.floor(y/cellSize)
		clickedCell = map[gridX][gridY]
		if clickedCell.occupied ~= true then
			for i=1,numPlayers do
				players[i]:moveTo(clickedCell, map)
			end
		end
	end
end