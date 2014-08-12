require('characters.character')

TestArrowCharacter = Character:extends{}

function TestArrowCharacter:__init(x, y)
	TestArrowCharacter.super.__init(self, x, y, 50 + (200 * math.random()), 10)
	self:setImage("graphics/img/Arrow.png")
end