local class = require('lib.30log.30log')
require('constants')

UIElement = class { x = 0, y = 0, width = 32, height = 32 }

function UIElement:__init(x, y, width, height)
  self.x,self.y = x,y
  self.width,self.height = width,height
  self.images = {}
  self.currentState = UI_NEUTRAL
  self.zIndex = 1
end

function UIElement:setLayer(layer)
	self.zIndex = layer
end

function UIElement:getLayer()
	return self.zIndex
end

function UIElement:containsPoint(x, y)
	return (x > self.x and x < (self.x + self.width) and y > self.y and y < (self.y + self.height))
end

function UIElement:setImage(state, image)
	self.images[state] = image
end

function UIElement:getImage()
	return self.images[self.currentState]
end

function UIElement:checkHover(x, y)
	if self:containsPoint(x, y) then
		if self.onHover ~= nil then
			self:onHover(x, y, true)
		else
			self.currentState = UI_HOVER
		end
	else
		if self.onHover ~= nil then
			self:onHover(x, y, false)
		else
			self.currentState = UI_NEUTRAL
		end
	end
end

function UIElement:setOnHover(callback)
	self.onHover = callback
end

function UIElement:checkMousePressed(x, y)
	if self:containsPoint(x, y) then
		if self.onMousePressed ~= nil then
			self:onMousePressed(x, y)
		else
			self.currentState = UI_PRESSED
		end
	end
end

function UIElement:setOnMousePressed(callback)
	self.onMousePressed = callback
end

function UIElement:checkMouseReleased(x, y)
	if self:containsPoint(x, y) then
		if self.onMouseReleased ~= nil then
			self:onClick(x, y)
		else
			self.currentState = UI_NEUTRAL
			self:clickFunction()
		end
	end
end

function UIElement:setOnMouseReleased(callback)
	self.onMouseReleased = callback
end

function UIElement:setClickFunction(callback)
	self.clickFunction = callback 
end