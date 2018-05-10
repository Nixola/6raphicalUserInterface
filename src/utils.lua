local utils = {}

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
			print(type(t[i]), type(v))
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


utils.font = setmetatable({}, {__index = function(self, k)
	assert(tonumber(k), "Attempt to query a non-numeric font size")
	self[k] = love.graphics.newFont(k)
	return self[k]
end})

return utils