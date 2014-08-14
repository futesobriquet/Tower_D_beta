local class = require('lib.30log.30log')
require('characters.character')
require('characters.testArrowCharacter')
require('towers.testCannonTower')
require('cell')
require('constants')
require('utils.timer')
require('towers.tower')

function love.load()
	players = {}
	towers = {}
	numPlayers = 0
	move = 0

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
	
	G = love.graphics
    shader = G.newShader("graphics/shaders/illuminate.glsl")
    diffuseBuffer = G.newCanvas(800, 600)
    diffuseBuffer:setFilter("nearest", "nearest")
	G.setBackgroundColor(0, 10, 100)
	mapTile = G.newImage('graphics/img/test_map_tiny.png')
	mapTileNormal = G.newImage('graphics/img/test_normal_map_tiny.png')
   
	tower = TestCannonTower:new(5*cellSize, 4*cellSize, map, players)
	table.insert(towers, tower)
	timer = Timer:new(0.3, addCharacter, nil)
	timer:start()
end

function addCharacter()
	local p = TestArrowCharacter:new(cellSize * 2, cellSize * 2)
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
	G.setColor(255, 255, 255, 255)
	shader:send('LightColor', {.6, .1, .1}, {.6, .1, .1}, {.6, .1, .1}, {.6, .1, .1}, {.6, .1, .1}, {.6, .1, .1})
	shader:send('LightPos', {300+ 200 * math.sin(move/20), 200, 3}, {300+ 200 * math.sin(move/15), 250, 3},{300+ 200 * math.sin(move/16), 350, 3}, {300+ 200 * math.sin(move/17), 400, 3}, {300+ 200 * math.sin(move/18), 450, 3}, {300+ 200 * math.sin(move/19), 200, 3})
	shader:send('numLights', 6)
	G.setShader(shader)
	render(G, shader)
	G.setShader()
	renderHUD(G, nil)
	move = move + 1
end

function render(G, shader)

	shader:send('useNormalMap', true)
	shader:send('normalTexture', mapTileNormal)
	for x=1, mapSize.x do
        for y=1, mapSize.y do
			cell = map[x][y]
            if cell.occupied == true then
				G.draw(mapTile, x * cellSize, y * cellSize)
			end
        end
    end
	shader:send('useNormalMap', false)
	for i=1,#players do
		players[i]:render(G, shader)
    end
	for i=1,#towers do
		towers[i]:render(G)
	end
end

function renderHUD(G, shader)
	for i=1,#players do
		players[i]:renderHUD(G, shader)
    end
end

function love.mousereleased(x, y, button)
	if button == 'l' then
		gridX = math.floor(x/cellSize)
		gridY = math.floor(y/cellSize)
		clickedCell = map[gridX][gridY]
		if clickedCell.occupied ~= true then
			local tower = TestCannonTower:new(gridX * cellSize,gridY * cellSize, map, players)
			table.insert(towers, tower)
			clickedCell.occupied = true
		end
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
	for i=#players,1,-1 do
		if players[i].health <= 0 then
			table.insert(toRemove, {index = i})
		end
	end
	for i=1,#toRemove do
		table.remove(players, toRemove[i].index)
	end
end