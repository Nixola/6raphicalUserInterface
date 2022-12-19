local dropdown = {}
local guiFolder = ...
guiFolder = guiFolder:match("^(.+)%.modules.-$")

local utils = require(guiFolder .. ".utils")

dropdown.styleSchema = {
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

dropdown.style = {
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

dropdown.new = function(self, parent, x, y, choices, style, width, height)
    local t = setmetatable({}, {__index = self})
    t.x = x
    t.y = y
    t.choices = choices
    t.selected = 1
    t.style = utils.merge(self.style, style)
    assert(utils.checkSchema(self.styleSchema, t.style))
    t.font = utils.font[t.style.text.size]
    t.height = height or t.font:getHeight() + t.style.padding*2
    local maxWidth = 0
    for i, v in ipairs(choices) do
        maxWidth = math.max(maxWidth, t.font:getWidth(v))
    end
    t.width = width or maxWidth + t.style.padding*2 + t.height

    t.panel = parent:add("panel", t.x, t.y + t.height)
    --t.panel = require(guiFolder .. ".modules.panel"):new(t.x, t.y + t.height)
    t.panel.shown = false
    --self.gui:remove(t.panel)
    local bstyle = utils.merge(t.style)
    bstyle.border.color = {0,0,0,0}
    for i, v in ipairs(t.choices) do
        local button = t.panel:add("button", t.x, t.y + i * 20, v, bstyle, maxWidth + t.style.padding * 2, 20)
        button.callback = function()
            t:select(i)
            t.panel.shown = false
        end
    end

    t.button = parent:add("button", t.x, t.y, choices[1], t.style, maxWidth)
    t.button.width = t.button.width + t.button.height
    t.button.callback = function()
        t.panel.shown = not t.panel.shown
    end

    return t
end


dropdown.update = function(self, dt)
    self.button:update(dt)
    self.panel:update(dt)
end


dropdown.select = function(self, n)
    self.selected = n
    self.button.text = self.choices[n]
    self.button:fitWidth()
    self.button.width = self.button.width + self.button.height
    if self.callback then
        self.callback(n)
    end
end


dropdown.refresh = function(self, choices)
    for i, item in self.panel.items do
        self.panel.items[i] = nil
    end
    local oldChoice = self.choices[self.selected]
    local chosen
    self.choices = choices
    for i, v in ipairs(self.choices) do
        if v == oldchoice then
            chosen = true
            self:select(i)
        end
        local button = self.panel:add("button", 0, (i-1) * 20, v, nil, nil, 20)
        button.callback = function()
            t:select(i)
        end
    end
end


dropdown.draw = function(self)
    self.button:draw()
    love.graphics.setColor(self.button.style.text.color)
    local margin = self.button.height / 3
    love.graphics.polygon("fill",
                          self.button.x + self.button.width - self.button.style.padding,           self.button.y + margin,
                          self.button.x + self.button.width - self.button.style.padding -2*margin, self.button.y + margin,
                          self.button.x + self.button.width - self.button.height / 2,              self.button.y + 2*margin
    )
    self.panel:draw()
end


dropdown.mousepressed = function(self, x, y, b)
    self.button:mousepressed(x, y, b)
    self.panel:mousepressed(x, y, b)
end


dropdown.mousereleased = function(self, x, y, b)
    self.button:mousereleased(x, y, b)
    self.panel:mousereleased(x, y, b)
end


return dropdown