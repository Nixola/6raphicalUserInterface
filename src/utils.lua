local utils = {}

local utf8 = require "utf8"
utils.utf8 = require((...):gsub("utils", "utf8"))

utils.clamp = function(min, x, max)
	if x < min then
		return min
	elseif x > max then
		return max
	end
	return x
end

utils.merge = function(...)
	
	local tables = {...}
	local t = {}

	local merged = {}
	for i = 1, table.maxn(tables) do
		local v = tables[i]
		if not v then --table does not exist
			goto continue
		end
		assert(type(v) == "table", "Tried to merge a non-table value")
		for ii, vv in pairs(v) do
			local newValue
			if type(vv) == "table" then
				local tables2 = {}
				for i = 1, table.maxn(tables) do
					local v = tables[i]
					if not v then goto continue end
					if v[ii] then
						assert(type(v[ii]) == "table", "Field " .. tostring(ii) .. " is both table and non-table")
						tables2[#tables2 + 1] = v[ii]
					end
					::continue::
				end
				newValue = utils.merge(unpack(tables2))
			else
				newValue = vv
			end
			t[ii] = newValue
		end
		::continue::
	end

	return t
end


utils.checkSchema = function(schema, t)
	for i, v in pairs(schema) do
		if type(t[i]) ~= type(v) and not (type(t[i]) == "nil" and type(v) == "boolean") then
			return nil, "Unmatched schema in key " .. i
		end
		if type(v) == "table" then
			local valid, err = utils.checkSchema(v, t[i])
			if not valid then
				return nil, "Unmatched schema in key " .. i .. "." .. err
			end
		end
	end
	return true
end


utils.AABB = function(x1, y1, w1, h1, x2, y2, w2, h2)
	return x1 < x2+w2 and
		x2 < x1+w1 and
		y1 < y2+h2 and
		y2 < y1+h1
end


utils.AABB∩ = function(x1, y1, w1, h1, x2, y2, w2, h2)
	local nx = math.max(x1, x2)
	local ny = math.max(y1, y2)
	local nw1 = x1 + w1 - nx
	local nw2 = x2 + w2 - nx
	local nw = math.min(nw1, nw2)
	local nh1 = y1 + h1 - ny
	local nh2 = y2 + h2 - ny
	local nh = math.min(nh1, nh2)

	local exists = nw > 0 and nh > 0
	if exists then
		return nx, ny, nw, nh
	end
end


utils.font = setmetatable({}, {__index = function(self, k)
	assert(tonumber(k), "Attempt to query a non-numeric font size")
	self[k] = love.graphics.newFont(k)
	return self[k]
end})


utils.utf8.getCharAtX = function(font, string, mousex)
	local prevw = 0
	local c = 0
	for i = 1, utf8.len(string) do
		local s = utils.utf8.sub(string, 1, i)
		local w = font:getWidth(s)
		if w > mousex then
			return i, (mousex - prevw) / (w - prevw)
		end
		prevw = w
		c = i
	end
	return c, 1
end


utils.lgDetailPrint = function(text, x, y, ro, sx, sy)
	local font = love.graphics.getFont()
	local r, g, b, a = love.graphics.getColor()
	local w, h = font:getWidth(text), font:getHeight()
	print(h, font:getAscent(), font:getBaseline(), font:getDescent())
	love.graphics.setColor(1, 1, 1, .1)
	love.graphics.rectangle("fill", x, y, w, h)
	love.graphics.setColor(r, g, b, a)
	love.graphics.print(text, x, y, ro, sx, sy)
	love.graphics.setColor(1, 0, 0, .5)
	love.graphics.line(x, y + font:getAscent() - .5, x + w, y + font:getAscent() - .5)
	love.graphics.setColor(0, 1, 0, .5)
	love.graphics.line(x, y + font:getBaseline() - .5, x + w, y + font:getBaseline() - .5)
	love.graphics.setColor(0, 0, 1, .5)
	love.graphics.line(x, y + font:getBaseline() - font:getDescent() - .5, x + w, y + font:getBaseline() - font:getDescent() - .5)
	love.graphics.setColor(r, g, b, a)
end


utils.getAABB = function(item)
	if not item.x and item.y and item.width and item.height then
		return false
	end
	return item.x, item.y, item.width, item.height
end
	


return utils