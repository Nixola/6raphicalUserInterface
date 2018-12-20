local panel = {}
local guiFolder = ...
guiFolder = guiFolder:match("^(.+)%.modules.-$")
--local Gui = require(guiFolder)
local utils = require(guiFolder .. ".utils")


panel.new = function(self, x, y, width, height, style)

	local t = self.gui:new(x, y, width, height)--Gui()
	print(style, style.bp)
	if style and style.bp then
		print("Adding backpanel")
		local bpStyle = utils.merge(style.bp, {position = {absolute = true}})
		local bp = t:add("backpanel", 0, 0, width, height, bpStyle)
	end

	return t
end

setmetatable(panel, {__call = panel.new})
return panel