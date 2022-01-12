
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

function getColor(array)
	local bonusID = 0;
	local bonusSize = 100000;
	for _, ID in pairs(array) do
		if #game.Map.Bonuses[ID].Territories < bonusSize then
			bonusID = ID;
			bonusSize = #game.Map.Bonuses[ID].Territories;
		end
	end
	if bonusID == 0 then return "#CCCCCC"; end
	return getBonusColor(bonusID)
end

function getBonusColor(bonusID)
	colorString = "#";
	for i = 2, 4 do
		colorString = colorString .. numberToHex(tonumber(game.Map.Bonuses[bonusID].Color[i]))
	end
	return colorString;
end


function numberToHex(value)
	lookUpList = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"};
	returnString = "";
	for i = 1, 16 do
		if value - (16 * i) < 0 then
			returnString = returnString .. lookUpList[i];
			value = value - (16 * (i - 1));
			break;
		end
	end
	if value == 0 then
		returnString = returnString .. lookUpList[1];
	else
		for i = 1, 16 do
			if value - i == 0 then
				returnString = returnString .. lookUpList[i+1];
				break;
			end
		end
	end
	return returnString;
end

function keyOf(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
    return nil
end

function getGroup(turnNumber, numberOfGroups)
	local reverseOrder = (math.ceil(turnNumber / numberOfGroups) % 2) == 1
	local remainder = (turnNumber - 1) % numberOfGroups
	if reverseOrder then group = numberOfGroups - remainder; else group = remainder + 1; end
	return group;
end

function valueInTable(t, v)
	for _, v2 in pairs(t) do
		if v2 == v then return true; end
	end
	return false;
end

function arrayReverse(t)
  local n = #t
  local i = 1
  while i < n do
    t[i],t[n] = t[n],t[i]
    i = i + 1
    n = n - 1
  end
  return t
end