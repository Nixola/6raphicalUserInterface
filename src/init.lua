local guiFolder = ...
guiFolder = guiFolder .. "/"


local gui = {}

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

	module.parent = gui

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

	--iterate through elements with tab?

	for i, item in self.items() do
		if item.wheelmoved then
			item:wheelmoved(dx, dy)
		end
	end
end


gui.keypressed = function(self, key, keycode, isRepeat)
	if not self.shown then return end -- if the gui is inactive, do not fire

	--iterate through elements with tab?

	for i, item in self.items() do
		if item.keypressed then
			item:keypressed(key, keycode, isRepeat)
		end
	end
end


gui.keyreleased = function(self, key, keycode)
	if not self.shown then return end -- if the gui is inactive, do not fire

	--iterate through elements with tab?

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