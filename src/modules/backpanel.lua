local backpanel = {}
local guiFolder = ...
guiFolder = guiFolder:match("^(.+)%.modules.-$")

local utils = require(guiFolder .. ".utils")

backpanel.styleSchema = {
	border = {
		style = "string",
		width = 1,
		color = {1, 1, 1}
	},
	background = {1, 1, 1}
}

backpanel.new = function(self, x, y, width, height, style)

	local t = setmetatable({}, {__index = self})

	t.x = x
	t.y = y
	t.width = width
	t.height = height

	t.style = utils.merge(self.style, style)
	assert(utils.checkSchema(self.styleSchema, t.style))
	return t
end


backpanel.draw = function(self)
	local style = self.style

	love.graphics.setColor(style.background)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, style.rx, style.ry, style.segments)
	
	love.graphics.setLineStyle(style.border.style)
	love.graphics.setLineWidth(style.border.width)

	love.graphics.setColor(style.border.color)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height, style.rx, style.ry, style.segments)
end

setmetatable(backpanel, {__call = backpanel.new})
return backpanel