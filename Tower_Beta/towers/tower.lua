local class = require('lib.30log.30log')
require('constants')
require('utils.timer')
require('utils.distanceCalcs')
require('towers.projectile')

Tower = class { grid_x = 2, grid_y = 2, x = 2 * cellSize, y = 2 * cellSize, range = 6, rate = 4, damage = 2, damageType = 'Normal', map = nil}
ATTACK_ORDER = {FIRST = 0, LAST = 1, STRONGEST = 2, ALL = 3}

function Tower:__init(x,y,range,rate,damage,damageType,map,creepList)
  self.x,self.y = x,y
  self.grid_x = math.floor(x / cellSize)
  self.grid_y = math.floor(y / cellSize)
  self.map = map
  self.cell = self.map[self.grid_x][self.grid_y]
  self.range = range * cellSize
  self.rate = rate --in seconds, also rename this so you actually mean 1/rate
  self.damageRange = damage
  self.damageType = damageType
  self.map[self.grid_x][self.grid_y].occupied = true
  self.creeps = creepList
  self.timer = Timer:new(self.rate, self.attack, {self})
  self.timer:start()
  self.toAttak = nil
  self.animations = {}
  self.currentAnimation = nil
  self.image = nil
  self.orientation = 0
  self.targetOrientation = 0
  self.canAttack = false
  self.projectileList = {}
end

function Tower:inRange(targetCreep)
	dist = euclideanDistance({x = self.x, y = self.y}, {x = targetCreep.x, y = targetCreep.y})
	if dist <= self.range then
		return true
	else
		return false
	end
end

function Tower:update(dt)
	self.timer:update(dt)
	for i=1,#self.projectileList do
		self.projectileList[i]:move(dt)
	end
	if math.abs(self.orientation - self.targetOrientation) > 0.25 then
		if (self.orientation <= 0 and self.targetOrientation <= 0) or (self.orientation >= 0 and self.targetOrientation >= 0) then
			if self.orientation < self.targetOrientation then
				self.orientation = (self.orientation + 0.25)
			else
				self.orientation = (self.orientation - 0.25)
			end
		else
			if (math.abs(self.orientation) + math.abs(self.targetOrientation)) <= math.pi then
				if self.orientation < self.targetOrientation then
					self.orientation = (self.orientation + 0.25)
				else
					self.orientation = (self.orientation - 0.25)
				end
			else
				if self.orientation > self.targetOrientation then
					self.orientation = (self.orientation + 0.25)
					if self.orientation > math.pi then
						self.orientation = -((2*math.pi) - self.orientation)
					end
				else
					self.orientation = (self.orientation - 0.25)
					if self.orientation < -math.pi then
						self.orientation = (2*math.pi) + self.orientation
					end
				end
			end
		end
	else
		self.orientation = self.targetOrientation
		if self.toAttack ~= nil and self.canAttack == true then
			--self.toAttack:takeDamage(self.damage, self.damageType)
			table.insert(self.projectileList, Projectile:new(self, self.toAttack, self:generateDamage(), self.damageType, 700))
			self.canAttack = false
			if self.attackType == ATTACK_ORDER.LAST then
				self.toAttack = nil
			end
		end
	end
end

function Tower:attack(tower)
	local self = tower[1]
	attackable = {}
	if self.toAttack ~= nil and (self.toAttack.health <= 0 or (self:inRange(self.toAttack) == false)) then
		self.toAttack = nil
	end
	if self.toAttack == nil then
		for i,creep in pairs (self.creeps) do
			if self:inRange(creep) == true then
				table.insert(attackable, creep)
			end
		end
		if self.attackType == ATTACK_ORDER.FIRST then
			local first = nil
			local currMaxDist = 1000000
			for i=1,#attackable do
				local dist = euclideanDistance({x=self.x, y=self.y}, {x=attackable[i].x, y=attackable[i].y})
				if dist < currMaxDist then
					currMaxDist = dist
					first = attackable[i]
				end
			end
			self.toAttack = first
		elseif self.attackType == ATTACK_ORDER.LAST then
			local last = attackable[#attackable]
			self.toAttack = last
		elseif self.attackType == ATTACK_ORDER.STRONGEST then
		
		elseif self.attackType == ATTACK_ORDER.ALL then
			for i=1,#attackable do
				attackable[i]:takeDamage(self.damage, self.damageType)
			end
		end
	end
	if self.toAttack ~= nil then
		self:rotateToFaceCreep(self.toAttack)
	end
end

function Tower:render(G)
	for i=1,#self.projectileList do
		self.projectileList[i]:render()
	end
	if self.currentAnimation == nil then
		if self.image == nil then
			G.rectangle("fill", self.x, self.y, cellSize, cellSize)
		else
			local width = self.image:getWidth()
			local height = self.image:getHeight()
			G.draw(self.image, self.x + cellSize/2, self.y + cellSize/2, self:getOrientation(), 1, 1, width / 2, height / 2)
		end
	end
end

function Tower:setOrientation(theta)
	self.orientation = theta
end

function Tower:getOrientation()
	return self.orientation
end

function Tower:setImage(imagePath)
	self.image = love.graphics.newImage(imagePath)
end

function Tower:generateDamage()
	local damage = math.random(self.damageRange[1], self.damageRange[2]) 
	return damage
end

function Tower:rotateToFaceCreep(creep)
	local cx = creep.x
	local cy = creep.y
	local sx = self.x
	local sy = self.y
	local dx = cx - sx
	local dy = cy - sy
	self.canAttack = true
	if self.damageType == 'Normal' then
		self.targetOrientation = math.atan2(dy, dx)
	elseif self.damageType == 'AOE' then
		self.targetOrientation = self.orientation
	else
		self.targetOrientation = 0
	end
end

function Tower:destroyProjectile(projectile)
	for i=1,#self.projectileList do --dumb, fix destructors
		if projectile == self.projectileList[i] then
			table.remove(self.projectileList, i)
			break
		end
	end
	collectgarbage()
end