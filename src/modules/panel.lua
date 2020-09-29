local panel = {}
local guiFolder = ...
guiFolder = guiFolder:match("^(.+)%.modules.-$")
--local Gui = require(guiFolder)
local utils = require(guiFolder .. ".utils")


panel.new = function(self, parent, x, y, width, height, style)

    local t = self.gui:new(x, y, width, height)--Gui()
    if style and style.bp then
        local bpStyle = utils.merge(style.bp, {position = {absolute = true}})
        local bp = t:add("backpanel", 0, 0, width, height, bpStyle)
    end

    t.inner = true

    return t
end

setmetatable(panel, {__call = panel.new})
return panel