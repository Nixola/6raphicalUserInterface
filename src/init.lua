local guiFolder = ...
guiFolder = guiFolder .. "/"

local utils = require(guiFolder:gsub("/", ".") .. "utils")


local gui = {}
gui.focused = 0

local modulesFolder = guiFolder:gsub("%.", "/") .. "modules/"
local modules = love.filesystem.getDirectoryItems(modulesFolder)

for i, fileName in ipairs(modules) do
    local moduleName = fileName:match("(.+)%.lua$")
    local modulePath = string.format("%s%s", modulesFolder:gsub('/', '.'), moduleName)
    local res, module = pcall(require, modulePath)
    if not res then
        error("Failed to load GUI module " .. fileName .. ": " .. module)
    end

    module.gui = gui

    gui[moduleName] = module
end


gui.update = function(self, dt)
    if not self.shown then return end -- if the gui is inactive, do not fire

    local mx, my = love.mouse.getPosition()
    if self.scroll then
        mx = mx - self.x
        my = my - self.y
    end
    
    for i, item in self.items() do
        local my = my
        if not (item.style and item.style.position and item.style.position.absolute) and self.scroll then
            my = my - self.scroll.y
        end
        if item.update then
            if item.hover then
                item.hovered = item:hover(mx, my)
            end
            item:update(dt)
        end
    end
end


gui.draw = function(self)
    if not self.shown then return end -- if the gui is inactive, do not fire
    
    for i, item in self.items() do
        if item.draw then
            local dx, dy
            if self.scroll then
                dx = self.x
                dy = self.y + ((item.style.position and item.style.position.absolute) and 0 or self.scroll.y)
                love.graphics.setScissor(self.x - 1, self.y - 1, self.width + 2 , self.height + 2)
                --[[love.graphics.push()
                love.graphics.translate(dx, dy)--]]
            end
            item:draw(dx, dy)
            love.graphics.setScissor()
            --[[
            if self.scroll then
                love.graphics.pop()
            end--]]
        end
    end
    if not self.debug then return end

    if self.scroll then
        love.graphics.setColor(255, 0, 0)
        local scissor = {love.graphics.getScissor()}
        love.graphics.setScissor()
        love.graphics.rectangle("line", self.x, self.y + self.scroll.y, self.width, self.scroll.maxHeight)
        love.graphics.setScissor(unpack(scissor))
    end

    if self:getFocusedItem() and utils.getAABB(self:getFocusedItem()) then
        love.graphics.setColor(0, 255, 0)
        local scissor = {love.graphics.getScissor()}
        love.graphics.setScissor()
        love.graphics.rectangle("line", self:adjustPosition(false, utils.getAABB(self:getFocusedItem())))
        love.graphics.setScissor(unpack(scissor))
    end

end


gui.hover = function(self, x, y)
    if self.scroll then
        return utils.AABB(self.x, self.y, self.width, self.height, x, y, 1, 1)
    else
        return true
    end
end


gui.mousepressed = function(self, x, y, b)
    if not self.shown then return end -- if the gui is inactive, do not fire

    if self.scroll then
        x = x - self.x
        y = y - self.y
    end

    local focused = false
    for i, item in self.items() do
        local y = y
        if not (item.style and item.style.position and item.style.position.absolute) and self.scroll then
            y = y - self.scroll.y
        end
        if item.hover and item:hover(x, y) then
            local y = y
            if item.focus then
                self:setFocus(item, true)
                focused = true
            end --force
            if item.mousepressed then item:mousepressed(x, y, b) end
        end
    end
    if not focused then
        self:unfocus(false, true)
    end
end


gui.mousereleased = function(self, x, y, b)
    if not self.shown then return end -- if the gui is inactive, do not fire

    if self.scroll then
        x = x - self.x
        y = y - self.y
    end
    
    for i, item in self.items() do
        local y = y
        if not (item.style and item.style.position and item.style.position.absolute) and self.scroll then
            y = y - self.scroll.y
        end
        if item.mousereleased then
            if item.hover and item:hover(x, y) then
                item:mousereleased(x, y, b)
            end
            item.clicked = false
        end
    end
end


gui.wheelmoved = function(self, dx, dy)
    if not self.shown then return end -- if the gui is inactive, do not fire

    local mx, my = love.mouse.getPosition()

    if self.scroll then
        mx = mx - self.x
        my = my - self.y
    end

    local caught = false

    for i, item in self.items() do
        if not (item.style and item.style.position and item.style.position.absolute) and self.scroll then
            my = my - self.scroll.y
        end
        if item.wheelmoved and item.hover and item:hover(mx, my) then
            item:wheelmoved(dx, dy)
            caught = true
        end
    end
    if not caught and self.scroll then
        self.scroll.y = utils.clamp(- (self.scroll.maxHeight - self.height), self.scroll.y + dy * 10, 0)
    end
end


gui.adjustPosition = function(self, absolute, x, y, ...)

    if self.scroll then
        x = self.x + x
        y = self.y + y
        if not absolute then
            y = y + self.scroll.y
        end
    end

    return x, y, ...
end


gui.keypressed = function(self, key, keycode, isRepeat)
    if not self.shown then return end -- if the gui is inactive, do not fire

    if key == "tab" then
        local ID = self.focused
        local reverse = love.keyboard.isDown("lshift", "rshift")

        if (not self.items[ID]) or self.items[ID]:unfocus(reverse) then
            local wrapFocus = not self.inner
            self:focus(ID, reverse, wrapFocus)
        end
        return
    end

    if self:getFocusedItem() and self:getFocusedItem().keypressed then
        self:getFocusedItem():keypressed(key, keycode, isRepeat)
    end
end


gui.focus = function(self, start, reverse, wrap)

    if type(start) == "boolean" then
        reverse = start
        start = nil
        wrap = false
    end
    
    local interval = reverse and -1 or 1
    start = start and (start + interval) or (reverse and #self.items or (interval + 1))
    local finish
    if wrap then
        finish = start + (#self.items + 1) * interval
    else
        finish = reverse and 1 or #self.items
    end

    for id = start, finish, interval do
        local id = (id - 1) % #self.items + 1
        if self.items[id].focus and self:setFocus(self.items[id], nil, reverse) then
            return true
        end
    end
end


gui.unfocus = function(self, reverse, force)

    local focused = self:getFocusedItem()
    
    if focused and focused.unfocus and not focused:unfocus() then
        return false
    end

    if force then
        self.focused = nil
        return true
    end
    if not self:focus(self.focused, reverse, false) then
        self.focused = nil
        return true
    end
end


gui.setFocus = function(self, newItem, force, reverse)

    local focused = self:getFocusedItem()

    if focused == newItem then
        return true
    end

    if newItem.focus and newItem:focus(reverse) then

        if focused and focused.focused and focused.unfocus then
            io.stdout:flush()
            focused:unfocus(reverse, force)
        end

        for i, v in ipairs(self.items) do
            if v == newItem then
                self.focused = i
                break
            end
        end
        return true
    end
end


gui.getFocusedItem = function(self)

    return self.focused and self.items[self.focused]
end


gui.keyreleased = function(self, key, keycode)
    if not self.shown then return end -- if the gui is inactive, do not fire

    if self:getFocusedItem() and self:getFocusedItem().keyreleased then
        self:getFocusedItem():keyreleased(key, keycode)
    end
end


gui.textinput = function(self, text)
    if not self.shown then return end -- if the gui is inactive, do not fire
    
    if self:getFocusedItem() and self:getFocusedItem().textinput then
        self:getFocusedItem():textinput(text)
    end
end


gui.show = function(self)
    self.shown = true
end


gui.hide = function(self)
    self.shown = false
end


gui.add = function(self, moduleName, ...)
    local module
    if type(moduleName) == "string" then
        assert(self[moduleName], "Attempt to add unexisting object - " .. moduleName)
        module = self[moduleName]
    elseif type(moduleName) == "table" then
        assert(moduleName.new, "Attempt to add unsupported module")
        module = moduleName
    else
        error("Attempt to add invalid module")
    end

    local newItem = module:new(self, ...)

    self.items[#self.items + 1] = newItem
    newItem.managed = true

    if self.scroll then

        self.scroll.maxHeight = math.max(self.scroll.maxHeight, newItem.y + newItem.height)

    end


    return newItem
end


gui.remove = function(self, item)
    local done = false
    for i, v in ipairs(self.items) do
        if item == v then
            table.remove(self.items, i)
            break
        end
    end
    assert(done, "Attempt to remove a non-existing item")
end


gui.new = function(self, x, y, width, height)
    
    local t = setmetatable({}, {__index = self})
    t.shown = true

    t.items = setmetatable({}, {__call = function(self) return ipairs(self) end})

    if x and y and width and height then
        t.scroll = {}
        t.scroll.y = 0
        t.scroll.maxHeight = 0
        t.x = x
        t.y = y
        t.width = width
        t.height = height
    end
    return t
end


return setmetatable(gui, {__call = gui.new})