local class = require('lib.30log.30log')
require('constants')

Tower = class { grid_x = 2, grid_y = 2, x = 2 * cellSize, y = 2 * cellSize, range = 6, rate = 4, damage = 2, damageType = 'Normal', lastAttackTime = -1, map = nil}

function Tower:__init(x,y,range,rate,damage,damageType,map)
  self.x,self.y = x,y
  self.grid_x = x / cellSize
  self.grid_y = y / cellSize
  self.map = map
  self.cell = self.map[self.grid_x][self.grid_y]
  self.range = range
  self.rate = rate --in seconds, also rename this so you actually mean 1/rate
  self.damage = damage
  self.damageType = 'Normal'
  self.lastAttackTime = -1
end

function Tower:inRange(targetCreep)
	targetCell = self.map[targetCreep.grid_x][targetCreep.grid_y] -- pretty bad
	dist = euclidianDistance(self.cell, targetCell)
	if dist <= self.range then
		return true
	else
		return false
	end
end

function Tower:attack(creepList)
	now = love.timer.getTime()
	if now - self.lastAttackTime >= self.rate then
		attackable = {}
		for i,creep in pairs(creepList) do
			if self:inRange(creep) == true then
				table.insert(attackable,creep)
			end
		end
		if attackable[1] then --dumb index check bad fix
			-- for i,v in pairs(attackable) do
				-- print('Index: ' .. i .. ' Value: ' .. v)
			-- end
			hitCreep = attackable[1] --dumb-ish
			hitCreep:takeDamage(self.damage, self.damageType)
			self.lastAttackTime = now
		end
	end
end
function euclidianDistance(startCell, endCell)
	distance = math.sqrt((startCell.x-endCell.x)^2+(startCell.y-endCell.y)^2)
	return distance
end