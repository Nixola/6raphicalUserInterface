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

gui:add("button", 100, 100, "TEST", {
	padding = 3,
	border = {
		style = "smooth",
		width = 1,
		color = {7/8, 7/8, 7/8}
	},
	background = {2/8, 2/8, 2/8},
	text = {
		size = 12,
		color = {1, 1, 1}
	},
	active = {4/8, 4/8, 4/8},
	rx = 3,
	ry = 3
})

love.draw = function()
	gui:draw()
end