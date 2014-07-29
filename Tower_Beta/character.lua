local class = require('lib.30log.30log')
require('constants')

Character = class { grid_x = 2, grid_y = 2, x = 2 * cellSize, y = 2 * cellSize, speed = 40}

local movementTollerance = 0.02

function Character:__init(x,y,speed)
  self.x,self.y = x,y
  self.speed = speed
  self.grid_x = x / cellSize
  self.grid_y = y / cellSize
end

function Character:setPath(p) 
	self.path = p
	self.pathIndex = 1
	self.nextNode = path[self.pathIndex]
end

function Character:moveAlongPath(dt)
	if math.abs((self.x / cellSize) - self.nextNode.x) < movementTollerance and math.abs((self.y / cellSize) - self.nextNode.y) < movementTollerance then
		self.pathIndex = self.pathIndex + 1
		if self.pathIndex <= #self.path then
			self.nextNode = self.path[self.pathIndex]
		end
	end
	local dx = (self.nextNode.x - self.x/cellSize)
	if math.abs(dx) < movementTollerance then
		dx = 0
	end
	if dx ~= 0 then
		dx =  dx / (math.abs((self.nextNode.x - self.x/cellSize)))
	end
	
	local dy = (self.nextNode.y - self.y/cellSize)
	if math.abs(dy) < movementTollerance then
		dy = 0
	end
	if dy ~= 0 then
		 dy = dy / (math.abs((self.nextNode.y - self.y/cellSize)))
	end
	self.x = self.x + self.speed * dx * dt
	self.y =self.y + self.speed * dy * dt
end

