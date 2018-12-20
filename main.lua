local Gui = require 'src'
local gui = Gui()

local p = gui:add("panel", 200, 100, 400, 400, {
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

p:add("button", 16, 10, "DIO").callback = function() print("IT COULD WORK") end
p:add("button", 16, 450, "AAAA").callback = function() print("wat") end

gui:add("button", 100, 100, "TEST").callback = function() print("first button") end

local b = gui:add("button", 100, 124, "TEST", {
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
b.callback = function(children)
	print("Firing", children.nick.text, children.pass.text, children.mail.text)
	children.nick:clear()
	children.pass:clear()
	children.mail:clear()
end

gui:add("textLine", 100, 148, 96, b, "nick", {rx = 2, ry = 2}, "Nickname")
gui:add("textLine", 100, 172, 96, b, "pass", {rx = 2, ry = 2}, "Password")
gui:add("textLine", 100, 196, 96, b, "mail", {rx = 2, ry = 2}, "E-mail")

gui:add("slider", 600, 100, 16, 400, 1/16)

love.update = function(dt)
	gui:update(dt)
end

love.draw = function()
	gui:draw()
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
end

love.keyreleased = function(key, keycode, isRepeat)
	gui:keyreleased(key, keycode, isRepeat)
end
