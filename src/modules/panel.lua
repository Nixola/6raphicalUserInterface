local panel = {}
local guiFolder = ...
guiFolder = guiFolder:match("^(.+)%.modules.-$")
--local Gui = require(guiFolder)


panel.new = function(self, x, y, width, height, style)

	local t = self.gui:new()--Gui()
	if style and style.bp then
		t:add("backpanel", x, y, width, height, style.bp)
	end

	return t
end

setmetatable(panel, {__call = panel.new})
return panel