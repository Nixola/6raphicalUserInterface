local guiFolder = ...
guiFolder = guiFolder .. "/"


local gui = {}
gui.focused = 0

local modulesFolder = guiFolder .. "modules/"
local modules = love.filesystem.getDirectoryItems(modulesFolder)

gui.items = setmetatable({}, {__call = function(self) return ipairs(self) end})

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
	
	for i, item in self.items() do
		if item.update then
			item:update(dt)
		end
	end
end


gui.draw = function(self)
	if not self.shown then return end -- if the gui is inactive, do not fire
	
	for i, item in self.items() do
		if item.draw then
			item:draw()
		end
	end
end


gui.mousepressed = function(self, x, y, b)
	if not self.shown then return end -- if the gui is inactive, do not fire

	for i, item in self.items() do
		if item.hover and item.focus and item:hover(x, y) then
			self:setFocus(item)
		end
		if item.mousepressed then
			item:mousepressed(x, y, b)
		end
	end
end


gui.mousereleased = function(self, x, y, b)
	if not self.shown then return end -- if the gui is inactive, do not fire
	
	for i, item in self.items() do
		if item.mousereleased then
			item:mousereleased(x, y, b)
		end
	end
end


gui.wheelmoved = function(self, dx, dy)
	if not self.shown then return end -- if the gui is inactive, do not fire

	for i, item in self.items() do
		if item.wheelmoved then
			item:wheelmoved(dx, dy)
		end
	end
end


gui.keypressed = function(self, key, keycode, isRepeat)
	if not self.shown then return end -- if the gui is inactive, do not fire

	if key == "tab" then
		local ID = self.focused
		local nextID = ID
		local isPrev = love.keyboard.isDown("lshift", "rshift")

		--[[elseif key == "tab" then
		local siblings = self.parent.children
		local ID = siblings[self]

		local nextID
		repeat
			nextID = love.keyboard.isDown("lshift", "rshift") and ((ID - 2) % #siblings + 1) or (ID % #siblings + 1)
		until
			siblings[nextID].focus or nextID == ID
		self.cursorTime = nil
		siblings[nextID]:focus()--]]

		if (not self.items[ID]) or self.items[ID]:unfocus() then

			repeat
				print("Switching", ID, nextID)
				nextID = isPrev and ((nextID - 2) % #self.items + 1) or (nextID % #self.items + 1)
				print(nextID)
			until
				self.items[nextID].focus or nextID == ID
			self:setFocus(self.items[nextID])
		end
	end

	--iterate through elements with tab?

	for i, item in self.items() do
		if item.keypressed then
			item:keypressed(key, keycode, isRepeat)
		end
	end
end


gui.keyreleased = function(self, key, keycode)
	if not self.shown then return end -- if the gui is inactive, do not fire

	for i, item in self.items() do
		if item.keyreleased then
			item:keyreleased(key, keycode)
		end
	end
end


gui.textinput = function(self, text)
	if not self.shown then return end -- if the gui is inactive, do not fire
	
	for i, item in self.items() do
		if item.textinput then
			item:textinput(text)
		end
	end
end


gui.setFocus = function(self, newItem)
	if self.items[self.focused] and self.items[self.focused].unfocus and newItem.focus then
		self.items[self.focused]:unfocus(true) --force
	end
	if newItem.focus then
		newItem:focus()
		for i, v in ipairs(self.items) do
			if v == newItem then
				self.focused = i
				break
			end
		end
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

	local newItem = module:new(...)

	self.items[#self.items + 1] = newItem
	newItem.managed = true

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


gui.new = function(self)
	
	local t = setmetatable({}, {__index = self})
	t.shown = true

	return t
end



return setmetatable(gui, {__call = gui.new})