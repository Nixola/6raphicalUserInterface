local text = {}
local guiFolder = ...
guiFolder = guiFolder:match("^(.+)%.modules.-$")

local utils = require(guiFolder .. ".utils")

text.styleSchema = { -- base style schema; minimum properties needed for it to work.

}

text.style = {
	font = utils.font[14],
	color = {1, 1, 1, 1},
	width = math.huge,
	align = "left"
}


text.new = function(self, parent, x, y, text, style)
    local t = setmetatable({}, {__index = self})
    t.x = x
    t.y = y
    t.text = text
    t.style = utils.merge(self.style, style)
    assert(utils.checkSchema(self.styleSchema, t.style))

    local w, wrap = t.style.font:getWrap(text, t.style.width)
    t.width = style.width and math.max(w, style.width) or w
    t.height = t.style.font:getHeight() * #wrap

    return t
end


text.draw = function(self, dx, dy)
    dx, dy = dx or 0, dy or 0
    local x, y = dx + self.x, dy + self.y

    local style = self.style
    love.graphics.setColor(style.color)
    love.graphics.setFont(style.font)
    love.graphics.printf(self.text, x, y, style.width, style.align)
end


return text