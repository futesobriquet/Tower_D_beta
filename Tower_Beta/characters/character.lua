local class = require('lib.30log.30log')
local search = require('utils.search')
require('constants')

Character = class { grid_x = 2, grid_y = 2, x = 2 * cellSize, y = 2 * cellSize, speed = 1, health = 10}

function Character:__init(x,y,speed,health)
  self.x,self.y = x,y
  self.speed = speed
  self.grid_x = x / cellSize
  self.grid_y = y / cellSize
  self.destination = {x = self.grid_x, y = self.grid_y}
  self.health = health
  self.orientation = 0
  self.animations = {}
  self.currentAnimation = nil
end

function Character:moveTo(cell, map)
	if map == nil then
		return
	end
	
	if self.path == nil then
		self.destination = cell
		local path = search.findShortestPath(map[math.floor(self.x/cellSize)][math.floor(self.y/cellSize)], cell, map, {x = self.x, y = self.y})
		if path ~= nil then
			self:setPath(path, true)
		end
	else
		local index
		local gx = math.floor(self.x/cellSize)
		local gy = math.floor(self.y/cellSize)
		self.destination = cell
		local i = findIndexInPath(gx, gy, self.path)
		if i ~= -1 then
			local newPath = {}
			for j = 1, i + 1 do
				newPath[j] = self.path[j]
			end
			self:setPath(newPath, false)
		end
	end
end

function Character:setPath(p, reset)
	if p == nil or #p < 2 then
		return
	end
	self.path = p
	self.pathList = {}
	if reset == true or self.totalX == nil or self.totalY == nil then
		self.totalX = 0
		self.totalY = 0
	end
	
	local curent_dx = self.path[2].x - self.path[1].x
	local curent_dy = self.path[2].y - self.path[1].y
	local last_dx = curent_dx
	local last_dy = curent_dy
	local start = 1
	local listIndex = 1
	for i=2,#self.path do
		local nextCell = self.path[i]
		local curCell = self.path[i - 1]
		curent_dx = nextCell.x - curCell.x
		curent_dy = nextCell.y - curCell.y
		if curent_dx ~= 0 and curent_dx == last_dx then
			last_dx = curent_dx
		elseif curent_dy ~= 0 and curent_dy == last_dy then
			last_dy = curent_dy
		else
			if listIndex - 1 > 0 then
				table.insert(self.pathList, makePathSegment(self.path, start, i - 1, last_dx, last_dy, self.pathList[listIndex - 1]))
			else
				table.insert(self.pathList, makePathSegment(self.path, start, i - 1, last_dx, last_dy, nil))
			end
			start = i - 1
			listIndex = listIndex + 1
			last_dx = curent_dx
			last_dy = curent_dy
		end
	end
	table.insert(self.pathList, makePathSegment(self.path, start, #self.path, last_dx, last_dy, self.pathList[#self.pathList]))
	--self:addSmoothCurvesToPath()
	--print('pathList length: ' .. #self.pathList)
end

function Character:addSmoothCurvesToPath()
	local newArcs = {}
	for i=1,#self.pathList-1 do
		local segment = self.pathList[i]
		local nextSegment = self.pathList[i + 1]
		local dx = segment.endPoint.x - segment.startPoint.x
		local dy = segment.endPoint.y - segment.startPoint.y
		local next_dx = nextSegment.endPoint.x - nextSegment.startPoint.x
		local next_dy = nextSegment.endPoint.y - nextSegment.startPoint.y
		if dx > 0 then
			segment.endPoint.x = segment.endPoint.x - 0.5
			if next_dy > 0 then
				nextSegment.startPoint.y = nextSegment.startPoint.y + 0.5
			elseif next_dy < 0 then
				nextSegment.startPoint.y = nextSegment.startPoint.y - 0.5
			end
		elseif dx < 0 then
			segment.endPoint.x = segment.endPoint.x + 0.5
			if next_dy > 0 then
				nextSegment.startPoint.y = nextSegment.startPoint.y + 0.5
			elseif next_dy < 0 then
				nextSegment.startPoint.y = nextSegment.startPoint.y - 0.5
			end
		elseif dy > 0 then
			segment.endPoint.y = segment.endPoint.y - 0.5
			if next_dx > 0 then
				nextSegment.startPoint.x = nextSegment.startPoint.x + 0.5
			elseif next_dx < 0 then
				nextSegment.startPoint.x = nextSegment.startPoint.x - 0.5
			end
		elseif dy < 0 then
			segment.endPoint.y = segment.endPoint.y + 0.5
			if next_dx > 0 then
				nextSegment.startPoint.x = nextSegment.startPoint.x + 0.5
			elseif next_dx < 0 then
				nextSegment.startPoint.x = nextSegment.startPoint.x - 0.5
			end
		end
		segment.length = segment.length - (cellSize/2)
		nextSegment.length = nextSegment.length - (cellSize/2)
		nextSegment.dist = segment.dist + segment.length + (math.pi * (cellSize/2))
		--print('segment start: ' .. segment.startPoint.x .. ', ' .. segment.startPoint.y)
		table.insert(newArcs, {index = i, segment = makeCircularPathSegment(segment.endPoint, nextSegment.startPoint, dx, dy, segment)})
	end
	for i=1,#newArcs do
		table.insert(self.pathList, newArcs[i].index + 1, newArcs[i].segment)
	end
end

function Character:moveAlongPath(dt, map)
	if self.path ~= nil then
		for i = 1, #self.path do
			if (map[self.path[i].x][self.path[i].y]).occupied == true then
				local characterIndex = findIndexInPath(math.floor(self.x / cellSize), math.floor(self.y / cellSize), self.path)
				local occupiedIndex = i
				if occupiedIndex > characterIndex then
					local newPath = {}
					for j = 1, i - 1 do
						newPath[j] = self.path[j]
					end
					self:setPath(newPath, false)
					break
				end
			end
		end
		local position = self:calculateNextPathPosition(dt)
		if position ~= nil then
			self.totalX = self.totalX + math.abs(position.x - self.x)
			self.totalY = self.totalY + math.abs(position.y - self.y)
			self.x = position.x
			self.y = position.y
		end
	else
		if ((math.floor(self.x / cellSize) ~= self.destination.x) or (math.floor(self.y / cellSize) ~= self.destination.y)) then
			self:setPath(search.findShortestPath(map[math.floor(self.x/cellSize)][math.floor(self.y/cellSize)], self.destination, map, {x = self.x, y = self.y}), true)
		end	
	end
	if self.currentAnimation ~= nil then
		self.currentAnimation:update(dt)
	end
end

function Character:calculateNextPathPosition(dt)
	local dist = dt * self.speed
	local totalDist = math.abs((self.totalX)) + math.abs((self.totalY)) + dist
	local segment = self:findSegmentInPath(totalDist)
	if segment ~= nil then
		--print ('prev dist: ' .. segment.dist)
		local diff = totalDist - segment.dist
		--print('diff: ' .. diff)
		local dir = segment.callback(diff)
		--print('dirx: ' .. dir.x .. ', diry: ' .. dir.y)
		self:calculateOrientation(dir)
		return {x = (segment.startPoint.x * cellSize) + dir.x, y = (segment.startPoint.y * cellSize) + dir.y}
	else 
		segment = self.pathList[#self.pathList]
		self.path = nil
		return {x = segment.endPoint.x * cellSize, y = segment.endPoint.y * cellSize}
	end
	return nil
end

function Character:findSegmentInPath(totalDistance)
	local accumulatedDistance = 0
	local index = 0
	while accumulatedDistance < totalDistance do
		index = index + 1
		if(index > #self.pathList) then
			return nil
		end
		local dist = self.pathList[index].length
		accumulatedDistance = accumulatedDistance + dist
	end
	if index <= #self.pathList then
		return self.pathList[index]
	end
	return nil
end

function makePathSegment(path, startIndex, endIndex, dx, dy, prevSegment)
	local length = (math.abs(path[endIndex].x - path[startIndex].x) * cellSize) + (math.abs(path[endIndex].y - path[startIndex].y) * cellSize)
	local startPoint = {x = path[startIndex].x, y = path[startIndex].y}
	local endPoint = {x = path[endIndex].x, y = path[endIndex].y}
	local dist
	if prevSegment then
		dist = prevSegment.dist + prevSegment.length
	else
		dist = 0
	end
	local callback
	if dx == -1 then
		callback = function(dt) return {x = - dt, y = 0} end
	elseif dx == 1 then
		callback = function(dt) return {x = dt, y = 0} end
	elseif dy == -1 then
		callback = function(dt) return {x =0, y = - dt} end
	else
		callback = function(dt) return {x = 0, y = dt} end
	end
	return {startPoint = startPoint, endPoint = endPoint, length = length, callback = callback, dist = dist}
end

function makeCircularPathSegment(startPoint, endPoint, dx, dy, prevSegment)
	print('making circular path segment')
	local radius = (cellSize / 2)
	local length = (math.pi / 2) * radius
	local startPoint = startPoint
	local endPoint = endPoint
	local dist
	if prevSegment ~= nil then
		dist = prevSegment.dist + prevSegment.length
	else
		dist = 0
	end
	local callback
	if dx == -1 then
		if startPoint.y > endPoint.y and startPoint.x > endPoint.x then
			callback = function(dt) return {x = -((cellSize / 2) * math.sin(dt/(cellSize/2))), y = (cellSize/2) - ((cellSize/2) * math.cos(dt/(cellSize/2)))} end
		elseif startPoint.x > endPoint.x and startPoint.y < endPoint.y then
			callback = function(dt) return {x = (cellSize / 2) * math.sin(dt/(cellSize/2)), y = -((cellSize/2) - ((cellSize/2) * math.cos(dt/(cellSize/2))))} end
		end
	elseif dx == 1 then
		if startPoint.x < endPoint.x and startPoint.y > endPoint.y then
			callback = function(dt) return {x = (cellSize / 2) * math.sin(dt/(cellSize/2)), y = -((cellSize/2) - ((cellSize/2) * math.cos(dt/(cellSize/2))))} end
		elseif startPoint.x < endPoint.x and startPoint.y < endPoint.y then
			callback = function(dt) return {x = (cellSize / 2) * math.sin(dt/(cellSize/2)), y = (cellSize/2) - ((cellSize/2) * math.cos(dt/(cellSize/2)))} end
		end
	elseif dy == -1 then
		if startPoint.x < endPoint.x and startPoint.y > endPoint.y then
			callback = function(dt) return {y = -((cellSize / 2) * math.sin(dt/(cellSize/2))), x = (cellSize/2) - ((cellSize/2) * math.cos(dt/(cellSize/2)))} end
		elseif startPoint.x > endPoint.x and startPoint.y > endPoint.y then
			callback = function(dt) return {y = -((cellSize / 2) * math.sin(dt/(cellSize/2))), x = -((cellSize/2) - ((cellSize/2) * math.cos(dt/(cellSize/2))))} end
		end
	else
		if startPoint.x < endPoint.x and startPoint.y < endPoint.y then
			callback = function(dt) return {y = (cellSize / 2) * math.sin(dt/(cellSize/2)), x = (cellSize/2) - ((cellSize/2) * (math.cos(dt/(cellSize/2))))} end
		elseif startPoint.x > endPoint.x and startPoint.y < endPoint.y then
			callback = function(dt) return {y = (cellSize / 2) * math.sin(dt/(cellSize/2)), x = -((cellSize/2) - ((cellSize/2) * math.cos(dt/(cellSize/2))))} end
		end
	end
	return {startPoint = startPoint, endPoint = endPoint, length = length, callback = callback, dist = dist}
end

function findIndexInPath(gx, gy, path)
	for i=1, #path do
		if path[i].x == gx and path[i].y == gy then
			return i
		end
	end
	return -1
end

function Character:calculateOrientation(dir)
	local dx, dy
	if dir.x == 0 then
		dx = dir.x
	else
		dx = dir.x / math.abs(dir.x)
	end
	if dir.y == 0 then
		dy = dir.y
	else
		dy = dir.y / math.abs(dir.y)
	end
	self.orientation = math.atan2(dy, dx)
end

function Character:setImage(imagePath)
	self.image = love.graphics.newImage(imagePath)
end

function Character:setNormalMap(normalMapPath)
	self.image = love.graphics.newImage(normalMapPath)
end

function Character:getImage()
	return self.image
end

function Character:getOrientation()
	return self.orientation
end

function Character:getNormalMap()
	return self.normalMap
end

function Character:takeDamage(damage, damageType)
	self.health = self.health - damage
end

function Character:render(G, shader)
	local width = self:getImage():getWidth()
	local height = self:getImage():getHeight()
	if shader ~= nil and self.normalMap ~= nil then
		shader:send('useNormalMap', true)
		shader:send('normalTexture', self.normalMap)
	end
	if self.currentAnimation == nil then
		G.draw(self:getImage(), self.x + cellSize/2, self.y + cellSize/2, self:getOrientation(), 1, 1, width / 2, height / 2)
	else
		self.currentAnimation:render(G, self.x + cellSize/2, self.y + cellSize/2, self:getOrientation(), 1, 1, width / 2, height / 2)
	end
	shader:send('useNormalMap', false)
end

function Character:renderHUD(G, shader)
	G.setColor(20, 255, 20)
	G.print(self.health, self.x + cellSize/4, self.y + cellSize/4)
end

function Character:animate(animation)
	self.currentAnimation = self.animations[animation]
end

function Character:stopAnimation()
	self.currentAnimation = nil
end