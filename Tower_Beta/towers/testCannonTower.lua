require('towers.tower')

TestCannonTower = Tower:extends{}

function TestCannonTower:__init(x, y, map, creepList)
	TestCannonTower.super.__init(self, x, y, 4, 0.8, {2,4}, 'Normal', map, creepList)
	self.attackType = ATTACK_ORDER.FIRST
	self:setImage("graphics/img/cannon_tiny.png")
end