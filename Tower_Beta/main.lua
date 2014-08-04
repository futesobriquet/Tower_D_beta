local class = require('lib.30log.30log')
require('character')
require('cell')
require('constants')
require('utils.timer')
require('tower')

function love.load()
	players = {}
	towers = {}
	numPlayers = 0

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
	tower = Tower:new(5*cellSize,4*cellSize,3,1,2,'Normal', map, players)
	table.insert(towers, tower)
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
	updateCreepList()
	timer:update(dt)
	for i=1,#players do
		players[i]:moveAlongPath(dt, map)
	end	
	for i=1,#towers do
		towers[i]:update(dt)
	end
end

function love.draw()
	for i=1,#players do
		players[i]:render()
    end
	for x=1, mapSize.x do
        for y=1, mapSize.y do
			cell = map[x][y]
            if cell.occupied == true then
				love.graphics.rectangle("line", x * cellSize, y * cellSize, cellSize, cellSize)
			end
        end
    end
	for i=1,#towers do
		towers[i]:render()
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
			for i=1,#players do
				players[i]:moveTo(clickedCell, map)
			end
		end
	end
end

function updateCreepList()
	toRemove = {}
	for i=1,#players do
		if players[i].health == 0 then
			table.insert(toRemove, {index = i})
		end
	end
	for i=1,#toRemove do
		table.remove(players, toRemove[i].index)
	end
end