local class = require('lib.30log.30log')
require('constants')
require('utils.timer')

Tower = class { grid_x = 2, grid_y = 2, x = 2 * cellSize, y = 2 * cellSize, range = 6, rate = 4, damage = 2, damageType = 'Normal', map = nil}
ATTACK_ORDER = {FIRST = 0, LAST = 1, STRONGEST = 2, ALL = 3}

function Tower:__init(x,y,range,rate,damage,damageType,map,creepList)
  self.x,self.y = x,y
  self.grid_x = x / cellSize
  self.grid_y = y / cellSize
  self.map = map
  self.cell = self.map[self.grid_x][self.grid_y]
  self.range = range * cellSize
  self.rate = rate --in seconds, also rename this so you actually mean 1/rate
  self.damage = damage
  self.damageType = 'Normal'
  self.map[self.grid_x][self.grid_y].occupied = true
  self.creeps = creepList
  self.timer = Timer:new(self.rate, self.attack, {self})
  self.timer:start()
  self.attackType = ATTACK_ORDER.FIRST
  self.toAttak = nil
  self.animations = {}
  self.currentAnimation = nil
end

function Tower:inRange(targetCreep)
	dist = euclidianDistance({x = self.x, y = self.y}, {x = targetCreep.x, y = targetCreep.y})
	if dist <= self.range then
		return true
	else
		return false
	end
end

function Tower:update(dt)
	self.timer:update(dt)
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
			local currMaxDist = 100000
			for i=1,#attackable do
				local dist = euclidianDistance({x=self.x, y=self.y}, {x=attackable[i].x, y=attackable[i].y})
				if dist < currMaxDist then
					currMaxDist = dist
					first = attackable[i]
				end
			end
			self.toAttack = first
		elseif self.attackType == ATTACK_ORDER.LAST then
			local last = nil
			local currMinDist = -1
			for i=1,#attackable do
				local dist = euclidianDistance({x=self.x, y=self.y}, {x=attackable[i].x, y=attackable[i].y})
				if dist >= currMinDist then
					currMinDist = dist
					last = attackable[i]
				end
			end
			self.toAttack = last
		elseif self.attackType == ATTACK_ORDER.STRONGEST then
		
		elseif self.attackType == ATTACK_ORDER.ALL then
			for i=1,#attackable do
				attackable[i]:takeDamage(self.damage, self.damageType)
			end
		end
	end
	if self.toAttack ~= nil then
		self.toAttack:takeDamage(self.damage, self.damageType)
	end
end

function euclidianDistance(startCell, endCell)
	distance = math.sqrt((startCell.x-endCell.x)^2+(startCell.y-endCell.y)^2)
	return distance
end

function Tower:render(G)
	if self.currentAnimation == nil then
		G.rectangle("fill", self.x, self.y, cellSize, cellSize)
	else
	
	end
end