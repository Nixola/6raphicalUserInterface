local button = {}
local guiFolder = ...
guiFolder = guiFolder:match("^(.+)%.modules.-$")

local utils = require(guiFolder .. ".utils")

button.styleSchema = { -- base style schema; minimum properties needed for it to work.
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
    idle = {1, 1, 1},
    active = {1, 1, 1}
}

button.style = {
    padding = 3,
    border = {
        style = "smooth",
        width = 1,
        color = {7/8, 7/8, 7/8}
    },
    text = {
        size = 12,
        color = {1, 1, 1}
    },
    idle = {4/8, 4/8, 4/8},
    hover = {5/8, 5/8, 5/8},
    active = {3/8, 3/8, 3/8},
    clicked = {2/8, 2/8, 2/8}
}
--[[
Buttons have four states.
Not clicked and not hovered (style.idle)
hovered, not clicked (style.hover)
clicked and hovered (style.clicked)
clicked and not hovered (style.active), before releasing the mouse]]

button.new = function(self, parent, x, y, text, style, width, height)
    local t = setmetatable({}, {__index = self})
    t.x = x
    t.y = y
    t.text = text
    t.style = utils.merge(self.style, style)
    assert(utils.checkSchema(self.styleSchema, t.style))
    t.font = utils.font[t.style.text.size]
    t.width = width or t.font:getWidth(t.text) + t.style.padding*2
    t.height = height or t.font:getHeight() + t.style.padding*2

    t.children = {}

    return t
end


button.fitWidth = function(self)
    self.width = self.font:getWidth(self.text) + self.style.padding*2
end


button.addChild = function(self, child, name)
    if self.children[name] then
        error("Child \"" .. name .. "\" already exists.")
    end
    self.children[name] = child
    self.children[#self.children + 1] = child
    self.children[child] = #self.children
end


button.update = function(self, dt)
    --self.hovered = utils.AABB(self.x, self.y, self.width, self.height, love.mouse.getX(), love.mouse.getY(), 1, 1)
end


button.draw = function(self, dx, dy)
    dx, dy = dx or 0, dy or 0
    local x, y = dx + self.x, dy + self.y
    local style = self.style
    love.graphics.setColor(
        self.clicked and (self.hovered and (style.clicked or style.active) or style.active) or
        self.hovered and style.hover or style.idle)
    love.graphics.rectangle("fill", x, y, self.width, self.height, style.rx, style.ry, style.segments)

    love.graphics.setFont(self.font)
    love.graphics.setColor(style.text.color)
    love.graphics.print(self.text, x + style.padding, y + style.padding)
    --utils.lgDetailPrint(self.text, x + style.padding, y + style.padding)

    love.graphics.setLineWidth(style.border.width)
    love.graphics.setLineStyle(style.border.style)
    love.graphics.setColor(style.border.color)
    love.graphics.rectangle("line", x, y, self.width, self.height, style.rx, style.ry, style.segments)
end


button.mousepressed = function(self, x, y, b)
    print("AAA")
    if b == 1 and self:hover(x, y) then
        self.clicked = true
    end
end


button.mousereleased = function(self, x, y, b)
    if b == 1 and self.clicked then
        if self.callback and self.hovered then
            self:fire()
        end
        self.clicked = false
    end
end


button.fire = function(self)
    self.callback(self.children)
end

button.hover = function(self, x, y)
    return utils.AABB(self.x, self.y, self.width, self.height, x, y, 1, 1)
end


return button