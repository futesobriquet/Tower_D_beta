local class = require('lib.30log.30log')
local anim8 = require('lib.anim8.anim8')

Animation = class { image = nil, frameWidth = 0, frameHeight = 0, duration = 0}

function Animation:__init(image, fw, fh, duration, loops, onLoop, ...)
	self.image = love.graphics.newImage(image)
	self.imageWidth = self.image:getWidth()
	self.imageHeight = self.image:getHeight()
	self.duration = duration
	self.fw = fw
	self.fh = fh
	self.grid = anim8.newGrid(self.fw, self.fh, self.imageWidth, self.imageHeight)
	if loops == true then
		self.anim = anim8.newAnimation(self.grid(...), self.duration)
	else
		self.anim = anim8.newAnimation(self.grid(...), self.duration, onLoop)
	end
end

function Animation:setShader(shader, args)
	self.shader = shader
	self.shaderArgs = args
end

function Animation:update(dt)
	self.anim:update(dt)
end

function Animation:render(G, x, y, r, sx, sy, ox, oy, ...)
	if self.shader ~= nil then
		for key,value in pairs(self.shaderArgs) do
			self.shader:send(key, value)
		end
		G.setShader(self.shader)
	end
	self.anim:draw(G, self.image, x, y, r, sx, sy, ox, oy, ...)
	if self.shader ~= nil then
		G.setShader()
	end
end
