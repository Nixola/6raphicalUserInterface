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
				for i, v in ipairs(tables) do
					if v[ii] then
						assert(type(v[ii]) == "table", "Field " .. tostring(ii) .. " is both table and non-table")
						tables2[#tables2 + 1] = v[ii]
					end
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
			return false
		end
		if type(v) == "table" then
			if not utils.checkSchema(v, t[i]) then
				return false
			end
		end
	end
	return true
end

return utils