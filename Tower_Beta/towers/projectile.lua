local class = require('lib.30log.30log')
require('constants')
require('utils.timer')
require('utils.distanceCalcs')

Projectile = class {tower = nil, creep = nil, start = {}, dest = {}, speed = 200, headingRatio = {}}

function Projectile:__init(tower, creep, damage, damageType, speed)
	self.tower = tower
	self.creep = creep
	self.damage = damage
	self.start.x = self.tower.x + (cellSize / 2) --tower:getX() should be methods to recover these and others??
	self.start.y = self.tower.y + (cellSize / 2) --tower:getY()
	self.dest.x = self.creep.x + (cellSize / 2) --creep:getX() 
	self.dest.y = self.creep.y + (cellSize / 2) --:getY()
	self.x = self.start.x
	self.y = self.start.y
	self.speed = speed
	self.headingMag = math.sqrt((self.dest.x - self.start.x)^2 + (self.dest.y - self.start.y)^2)
	self.headingRatio.x = (self.dest.x - self.start.x)/self.headingMag
	self.headingRatio.y = (self.dest.y - self.start.y)/self.headingMag
	self.distanceToGoal = euclideanDistance({x=tower.x, y=tower.y}, {x=creep.x, y=creep.y}) --decide on inheritance I guess
	self.accumulatedDistance = 0
	self.image = nil
	self:setImage('graphics/img/cannonball_tiny.png')
end

function Projectile:move(dt)
	local travelledDistance = self.speed * dt
	self.x = self.x + self.headingRatio.x * travelledDistance
	self.y = self.y + self.headingRatio.y * travelledDistance
	self.accumulatedDistance = self.accumulatedDistance + travelledDistance
	if self.accumulatedDistance >= self.distanceToGoal then
		self.creep:takeDamage(self.damage, self.damageType)
		self:destroy()
	end
end

function Projectile:render()
	local width = self.image:getWidth()
	local height = self.image:getHeight()
	love.graphics.draw(self.image, self.x, self.y, 0, 1, 1, width / 2, height / 2) --stand-in for projectile image
end

function Projectile:destroy()
	self.tower:destroyProjectile(self)
end

function Projectile:setImage(path)
	self.image = love.graphics.newImage(path)
end
