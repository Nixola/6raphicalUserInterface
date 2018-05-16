local textLine = {}
local guiFolder = ...
guiFolder = guiFolder:match("^(.+)%.modules.-$")

local utils = require(guiFolder .. ".utils")
local utf8 = require "utf8"

textLine.styleSchema = {
	padding = 1,
	border = {
		style = "smooth",
		width = 1,
		color = {1, 1, 1}
	},
	text = {
		size = 1,
		color = {1, 1, 1},
		margin = {
			left = 1,
			right = 1
		}
	},
	cursor = {
		duration = 1,
		period = 1,
		width = 1,
		style = "smooth"
	},
	background = {1, 1, 1}
}

textLine.style = {
	padding = 4,
	border = {
		style = "smooth",
		width = 1,
		color = {7/8, 7/8, 7/8}
	},
	text = {
		size = 12,
		color = {1, 1, 1},
		margin = {
			left = 1.25,
			right = 1.25
		}
	},
	cursor = {
		duration = .5,
		period = 1,
		width = 1,
		style = "rough",
		color = {1,1,1}
	},
	background = {3/8, 3/8, 3/8},
}

textLine.new = function(self, x, y, width, parent, name, style, text)
	local t = setmetatable({}, {__index = self})

	t.x = x
	t.y = y
	t.style = utils.merge(self.style, style)
	assert(utils.checkSchema(self.styleSchema, t.style))
	t.font = utils.font[t.style.text.size]
	t.width = width
	t.height = t.font:getHeight() + t.style.padding*2
	t.name = name
	t.text = text or ""
	t.printOffset = 0
	t.cursor = utf8.len(t.text)

	if parent then
		assert(parent.addChild, "Parent does not support children") -- call social services
		parent:addChild(t, name)
		self.parent = parent
	end

	return t
end


textLine.clear = function(self)
	self.text = ""
	self.printOffset = 0
	self.cursor = 0
end


textLine.focus = function(self)
	self.cursorTime = 0
	self.switched = true
end


textLine.hover = function(self, x, y)
	return utils.AABB(self.x, self.y, self.width, self.height, x, y, 1, 1)
end


textLine.update = function(self, dt)
	self.switched = false
	if self.cursorTime then
		self.cursorTime = self.cursorTime + dt
		while self.cursorTime > self.style.cursor.period do
			self.cursorTime = self.cursorTime - self.style.cursor.period
		end
	end
end



textLine.draw = function(self)
	local style = self.style
	love.graphics.setColor(style.background)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, style.rx, style.ry, segments)

	love.graphics.setColor(style.text.color)
	love.graphics.setFont(self.font)
	local textWidth = self.font:getWidth(self.text)
	local cursorX = self.font:getWidth(utils.utf8.sub(self.text, 1, self.cursor))
	local p
	if cursorX - self.printOffset < style.text.margin.left*style.text.size - style.padding and
	  self.printOffset > 0 then

		self.printOffset = -(style.text.margin.left*style.text.size - cursorX - style.padding)

	elseif cursorX - self.printOffset > self.width - style.padding - style.text.margin.right*style.text.size and
		self.printOffset + style.text.margin.right*style.text.size > 0 then

		self.printOffset = cursorX - self.width + style.padding + style.text.margin.right*style.text.size

	end
	self.printOffset = utils.clamp(0, self.printOffset, math.max(0, textWidth - self.width + style.padding * 2 + 1))
	love.graphics.setScissor(self.x + style.padding, self.y + style.padding, self.width - style.padding * 2, self.height - style.padding * 2)
	love.graphics.print(self.text, self.x + style.padding - self.printOffset, self.y + style.padding)
	--utils.lgDetailPrint(self.text, self.x + style.padding - self.printOffset, self.y + style.padding)
	if self.cursorTime and self.cursorTime < style.cursor.duration then
		love.graphics.setLineWidth(style.cursor.width)
		love.graphics.setLineStyle(style.cursor.style)
		love.graphics.setColor(style.cursor.color or style.text.color)
		local cx = self.x + style.padding - self.printOffset + cursorX + 1
		love.graphics.line(cx, self.y - style.padding, cx, self.y + self.height + style.padding)
	end

	love.graphics.setScissor()

	love.graphics.setColor(style.border.color)
	love.graphics.setLineWidth(style.border.width)
	love.graphics.setLineStyle(style.border.style)
	love.graphics.rectangle("line", self.x, self.y, self.width, self.height, style.rx, style.ry, segments)
end


textLine.mousepressed = function(self, x, y, b)
	if b == 1 then
		if self:hover(x, y) then
			self.cursorTime = 0
			local charPosition, portion = utils.utf8.getCharAtX(self.font, self.text, x - self.printOffset - self.x)
			self.cursor = charPosition + math.floor(portion + .5) - 1
		else
			self.cursorTime = nil
		end
	end
end


textLine.textinput = function(self, text)
	if not self.cursorTime then return end
	self.text = string.format("%s%s%s",
		utils.utf8.sub(self.text, 1, self.cursor),
		text,
		utils.utf8.sub(self.text, self.cursor + 1, utf8.len(self.text)))
	self.cursor = self.cursor + utf8.len(text)
end


textLine.keypressed = function(self, key, keycode, isRepeat)
	if not self.cursorTime then return end
	if self.switched then self.switched = false return end
	if key == "left" then
		self.cursor = math.max(self.cursor - 1, 0)
		self.cursorTime = 0
	elseif key == "right" then
		self.cursorTime = 0
		self.cursor = math.min(self.cursor + 1, utf8.len(self.text))
	elseif key == "backspace" and self.cursor ~= 0 then
		self.cursorTime = 0
		self.text = utils.utf8.sub(self.text, 1, self.cursor - 1) .. utils.utf8.sub(self.text, self.cursor + 1, -1)
		self.cursor = self.cursor - 1
	elseif key == "delete" and self.cursor ~= utf8.len(self.text) then
		self.cursorTime = 0
		self.text = utils.utf8.sub(self.text, 1, self.cursor) .. utils.utf8.sub(self.text, self.cursor + 2, -1)
	elseif key == "home" then
		self.cursor = 0
		self.cursorTime = 0
	elseif key == "end" then
	self.cursorTime = 0
		self.cursor = utf8.len(self.text)
	elseif key == "return" then
		self.cursorTime = 0
		if self.parent then
			self.parent:fire()
		elseif self.callback then
			if self.callback(self.text) then
				self:clear()
			end
		end
	elseif key == "tab" then
		local siblings = self.parent.children
		local ID = siblings[self]

		local nextID
		repeat
			nextID = love.keyboard.isDown("lshift", "rshift") and ((ID - 2) % #siblings + 1) or (ID % #siblings + 1)
		until
			siblings[nextID].focus or nextID == ID
		self.cursorTime = nil
		siblings[nextID]:focus()
	end

end


return textLine