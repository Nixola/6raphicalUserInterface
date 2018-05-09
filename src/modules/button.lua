local button = {}
local guiFolder = ...
guiFolder = guiFolder:match("^(.+)%.modules.-$")

local utils = require(guiFolder .. ".utils")

button.styleSchema = {
	padding = 1,
	border = {
		style = "smooth",
		width = 1,
		color = {1, 1, 1}
	},
	text = {
		size = 1,
		color = {1, 1, 1}
	},
	background = {1, 1, 1},
	active = {1, 1, 1}
}


button.new = function(self, x, y, text, style, width, height)
	local t = setmetatable({}, {__index = self})
	t.x = x
	t.y = y
	t.text = text
	t.style = utils.merge(self.style, style)
	assert(utils.checkSchema(self.styleSchema, t.style))
	t.font = utils.font[t.style.text.size]
	t.width = width or t.font:getWidth(t.text) + t.style.padding*2 + t.style.border.width
	t.height = height or t.font:getHeight() + t.style.padding*2 + t.style.border.width

	return t
end


button.draw = function(self)
	local style = self.style
	love.graphics.setColor(self.active and style.active or style.background)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, style.rx, style.ry, style.segments)

	love.graphics.setFont(self.font)
	love.graphics.setColor(style.text.color)
	love.graphics.print(self.text, self.x + style.padding, self.y + style.padding)

	love.graphics.setLineWidth(style.border.width)
	love.graphics.setLineStyle(style.border.style)
	love.graphics.setColor(style.border.color)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height, style.rx, style.ry, style.segments)
end


button.hover = function(self, x, y)
	


return button