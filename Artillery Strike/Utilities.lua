
function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end


function getTableLength(t)
	local count = 0;
	for i,_ in pairs(t) do
		count = count + 1;
	end
	return count;
end

function getTerritoriesInRange(game, terrID, range)
	local t = {};
	for conn, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
		t[conn] = 1;
	end
	if range > 1 then
		for i = 1, range - 1 do
			for j, v in pairs(t) do
				if v == i then
					for conn, _ in pairs(game.Map.Territories[j].ConnectedTo) do
						if t[conn] == nil then
							t[conn] = i + 1;
						end
					end
				end
			end
		end
	end
	t[terrID] = nil;
	return t;
end

function filter(list, func)
	local t = {};
	for i, v in pairs(list) do
		if func(i, v) then
			t[i] = v;
		end
	end
	return t;
end

function round(n)
	if n % 1 < 0.5 then
		return math.floor(n);
	else
		return math.ceil(n);
	end
end