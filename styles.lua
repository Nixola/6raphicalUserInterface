local styles = {}
local merge = require "src.utils".merge
local font = require "src.utils".font
styles.merge = function(self, ...)
	local keys = {...}
	local t = {}
	for i, v in ipairs(keys) do
		assert(self[v], "Style '" .. v .. "' doesn't exist.")
		t[#t+1] = self[v]
	end
	return merge(unpack(t))
end
setmetatable(styles, {__call = styles.merge})

styles.panel = {
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
}

styles.title = {
	font = font[12], 
	color = {6/8, 6/8, 6/8}, 
	width = 250, 
	align = "center"
}

styles.warning = {
	font = font[8],
	color = {4/8, 4/8, 4/8}
}

styles.right = {
	align = "right"
}

styles["100w"] = {
	width = 100
}

styles.rounded2px = {
	rx = 2,
	ry = 2
}

styles.rounded3px = {
	rx = 3,
	ry = 3
}

return styles