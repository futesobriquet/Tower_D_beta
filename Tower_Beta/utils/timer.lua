local class = require('lib.30log.30log')
require('constants')

Timer = class { interval = 100, callback = nil }

function Timer:__init(interval, callback, args)
  self.interval = interval
  self.callback = callback
  self.args = args
end

function Timer:start()
	self.started = true
	self.elapsed = 0
end

function Timer:stop()
	self.started = false
	self.elapsed = 0
end

function Timer:reset()
	self.elapsed = 0
end

function Timer:tick(dt)
	self.elapsed = self.elapsed + dt
	if self.elapsed >= self.interval then
		if self.args == nil then
			self.callback()
		else
			self.callback(self.args)
		end
		self.elapsed = 0
	end
end

function Timer:update(dt)
	if self.started == true then
		self:tick(dt)
	end
end