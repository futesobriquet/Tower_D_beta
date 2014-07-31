local class = require('lib.30log.30log')
require('character')
require('cell')
require('constants')

function love.load()
	player = Character:new(cellSize * 2, cellSize * 2,100)
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
end

function love.update(dt)
	player:moveAlongPath(dt, map)
end

function love.draw()
    love.graphics.rectangle("fill", player.x, player.y, cellSize, cellSize)
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
		gridX = math.floor(x/32)
		gridY = math.floor(y/32)
		clickedCell = map[gridX][gridY]
		clickedCell.occupied = not clickedCell.occupied
	end
	if button == 'r' then
		gridX = math.floor(x/32)
		gridY = math.floor(y/32)
		clickedCell = map[gridX][gridY]
		if clickedCell.occupied ~= true then
			player:moveTo(clickedCell, map)
		end
	end
end