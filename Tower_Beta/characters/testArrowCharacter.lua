require('characters.character')

TestArrowCharacter = Character:extends{}

function TestArrowCharacter:__init(x, y)
	TestArrowCharacter.super.__init(self, x, y, 50 + (200 * math.random()), 10)
	self:setImage("graphics/img/Arrow.png")
	local animHit = Animation:new('graphics/img/explosion17.png', 64, 64, 0.015, false, function() self.currentAnimation.anim:pauseAtStart() self.currentAnimation = nil end, 1, "1-5", 2, "2-5", 3, "3-5", 4, "4-5", 5, "5-5")
    self.animations = {hit = animHit}
end