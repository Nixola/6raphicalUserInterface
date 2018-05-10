local Gui = require 'src'
local gui = Gui()

gui:add("backpanel", 200, 100, 400, 400, {
	border = {
		style = "smooth",
		width = 1,
		color = {7/8, 7/8, 7/8}
	},
	background = {2/8, 2/8, 2/8},
	rx = 10,
	ry = 10,
	segments = 10
})

gui:add("button", 100, 100, "TEST").callback = function() print("first button") end

gui:add("button", 100, 124, "TEST", {
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
}).callback = function() print("second button") end

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
