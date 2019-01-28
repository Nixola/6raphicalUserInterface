local Gui = require 'src'
local gui = Gui()

local text = ""
local timer = 0
local flash = function(txt)
	text = txt
	timer = 1
end
local font = require "src.utils".font

local panel = gui:add("panel", 200, 100, 400, 400, {
	bp = {
		border = {
			style = "smooth",
			width = 1,
			color = {7/8, 7/8, 7/8}
		},
		background = {2/8, 2/8, 2/8},
		rx = 10,
		ry = 10,
		segments = 10
	}
})


do
	local p2 = function() end
	togglePrint = function()
		p2, print = print, p2
	end
end

local panelItems = {}
local guiItems = {}

panelItems.button1 = panel:add("button", 16, 10, "THING")
panelItems.button1.callback = function(children) flash(children.thing.text) end

panelItems.button2 = panel:add("button", 16, 450, "AAAA")
panelItems.button2.callback = function() flash("wat") end

panelItems.textLine1 = panel:add("textLine", 16, 30, 96, panelItems.button1, "thing")

panelItems.textLine2 = panel:add("textLine", 16, 50, 96, panelItems.button1, "thang")

panelItems.textLine3 = panel:add("textLine", 16, 70, 96, panelItems.button1, "thong")

thing = panelItems.textLine1


guiItems.button1 = gui:add("button", 100, 100, "TEST")
guiItems.button1.callback = function() flash("first button") end

guiItems.button2 = gui:add("button", 100, 124, "TEST", {
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
	idle = {2/8, 2/8, 2/8},
	hover = {3/8, 3/8, 3/8},
	active = {4/8, 4/8, 4/8},
	clicked = {5/8, 5/8, 5/8},
	rx = 3,
	ry = 3
})
guiItems.button2.callback = function(children)
	print("Firing", children.nick.text, children.pass.text, children.mail.text)
	children.nick:clear()
	children.pass:clear()
	children.mail:clear()
end

guiItems.textLine1 = gui:add("textLine", 100, 148, 96, guiItems.button2, "nick", {rx = 2, ry = 2}, "Nickname")
guiItems.textLine2 = gui:add("textLine", 100, 172, 96, guiItems.button2, "pass", {rx = 2, ry = 2}, "Password")
guiItems.textLine3 = gui:add("textLine", 100, 196, 96, guiItems.button2, "mail", {rx = 2, ry = 2}, "E-mail")

gui:add("slider", 600, 100, 16, 400, 1/16)

love.update = function(dt)
	gui:update(dt)
	timer = math.max(timer - dt, 0)
end

love.draw = function()
	love.graphics.setColor(1,1,1,1)
	gui:draw()
	love.graphics.setColor(1,1,1, timer^5)
	love.graphics.setFont(font[72])
	love.graphics.printf(text, 0, 200, 800, "center")
end

love.mousepressed = function(x, y, b)
	gui:mousepressed(x, y, b)
end

love.mousereleased = function(x, y, b)
	gui:mousereleased(x, y, b)
end

love.wheelmoved = function(dx, dy)
	gui:wheelmoved(dx, dy)
end

love.textinput = function(text)
	gui:textinput(text)
end

love.keypressed = function(key, keycode, isRepeat)
	gui:keypressed(key, keycode, isRepeat)
	--[[if key == "d" then
		togglePrint()
	end--]]
end

love.keyreleased = function(key, keycode, isRepeat)
	gui:keyreleased(key, keycode, isRepeat)
end