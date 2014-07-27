local class = require('lib.30log.30log')
require('character')
require('cell')
search = require('search')
require('constants')

function love.load()
	player = Character:new(cellSize * 2, cellSize * 2,80)
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

	print(player.grid_x)
	path = search.findShortestPath(map[player.grid_x][player.grid_y], map[2][12], map)
	search.printPath(path)
	player:setPath(path)
end

function love.update(dt)
	player:moveAlongPath(dt)
end

function love.draw()
    love.graphics.rectangle("fill", player.x, player.y, cellSize, cellSize)
    for x=1, mapSize.x do
        for y=1, mapSize.y do
            if walls[x][y] == 1 then
				love.graphics.rectangle("line", x * cellSize, y * cellSize, cellSize, cellSize)
            end
        end
    end
end