local class = require('lib.30log.30log')
local search = require('search')
require('constants')

Character = class { grid_x = 2, grid_y = 2, x = 2 * cellSize, y = 2 * cellSize, speed = 1}

local movementTollerance = 0.02

function Character:__init(x,y,speed)
  self.x,self.y = x,y
  self.speed = speed
  self.grid_x = x / cellSize
  self.grid_y = y / cellSize
  self.destination = {x = self.grid_x, y = self.grid_y}
end

function Character:moveTo(cell, map)
	if self.path == nil then
		self.destination = cell
		local path = search.findShortestPath(map[math.floor(self.x/cellSize)][math.floor(self.y/cellSize)], cell, map)
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
			self:setPath(search.findShortestPath(map[math.floor(self.x/cellSize)][math.floor(self.y/cellSize)], self.destination, map), true)
		end	
	end
end

function Character:calculateNextPathPosition(dt)
	local dist = dt * self.speed
	local totalDist = math.abs((self.totalX)) + math.abs((self.totalY)) + dist
	local segment = self:findSegmentInPath(totalDist)
	if segment ~= nil then
		local diff = totalDist - segment.dist
		local dir = segment.callback(diff)
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
	local startPoint = path[startIndex]
	local endPoint = path[endIndex]
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

function findIndexInPath(gx, gy, path)
	for i=1, #path do
		if path[i].x == gx and path[i].y == gy then
			return i
		end
	end
	return -1
end