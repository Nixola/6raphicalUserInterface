local slider = {}
local guiFolder = ...
guiFolder = guiFolder:match("^(.+)%.modules.-$")

local utils = require(guiFolder .. ".utils")

slider.styleSchema = {
	button = {
		width = 1,
		height = 1,
		idle = {1, 1, 1}
	},
	idle = {1, 1, 1}
}

slider.style = {
	button = {
		width = 0,
		height = 0,
		idle = {0, 0, 0, 0}
	},
	idle = {4/8, 4/8, 4/8},
	hover = {5/8, 5/8, 5/8},
	active = {3/8, 3/8, 3/8},
	clicked = {2/8, 2/8, 2/8},
	background = {1/8, 1/8, 1/8}
}


slider.new = function(self, x, y, width, height, span, style, value)
	local t = setmetatable({}, {__index = self})

	t.x = x
	t.y = y
	t.width = width
	t.height = height
	t.span = span

	t.value = value or 0

	t.direction = t.width >= t.height and "horizontal" or "vertical"

	return t
end


slider.hover = function(self, x, y)
	return utils.AABB(self.x, self.y, self.width, self.height, x, y, 1, 1)
end


slider.getSlider = function(self)
	local x, y, w, h
	if self.direction == "horizontal" then
		y = self.y
		w = self.span * (self.width - self.style.button.width * 2)
		h = self.height
		x = self.x + self.style.button.width + (self.value) * (self.width - self.style.button.width * 2)
	else
		x = self.x
		w = self.width
		h = self.span * (self.height - self.style.button.height * 2)
		y = self.y + self.style.button.height + (self.value) * (self.height - self.style.button.width * 2)
	end

	return x, y, w, h
end


slider.update = function(self, dt)
	if not self.active then return end
	local style = self.style

	local mx, my = love.mouse.getPosition()
	if not self:hover(mx, my) then
		self.clicked = false
	end

	if self.direction == "horizontal" then
		newValue = (mx - self.x - style.button.width - self.active.x) / (self.width - style.button.width*2)
	else
		newValue = (my - self.y - style.button.height - self.active.y) / (self.height - style.button.height*2)
	end
	
	self.value = utils.clamp(0, newValue, 1)
end



slider.draw = function(self)
	local style = self.style
	love.graphics.setColor(style.background)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.setColor(style.button.idle)
		--etc

	love.graphics.setColor(self.clicked and style.clicked or self.active and style.active or self.hover and style.hover or style.idle)
	local sx, sy, sw, sh = self:getSlider()
	love.graphics.rectangle("fill", sx, sy, sw, sh)
end


slider.mousepressed = function(self, x, y, b)
	if b == 1 and self:hover(x, y) then
		local sx, sy, sw, sh = self:getSlider()
		self.clicked = true
		self.active = {x = utils.clamp(0, x - sx, sw), y = utils.clamp(0, y - sy, sh)}
	end
end


slider.mousereleased = function(self, x, y, b)
	if b == 1 then
		self.clicked = false
		self.active = false
	end
end


return slider