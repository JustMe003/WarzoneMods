function getStructuresMap()
    local t = {};
    for i, v in pairs(WL.StructureType) do
	if i ~= "ToString" then
            t[v] = readableString(i);
	end
    end
    return t;
end

function readableString(s)
	local ret = string.upper(string.sub(s, 1, 1));
	for i = 2, #s do
		if string.sub(s, i, i) == string.lower(string.sub(s, i, i)) then
			ret = ret .. string.sub(s, i, i);
		else
			ret = ret .. " " .. string.lower(string.sub(s, i, i));
		end
	end
	return ret;
end

function getGroupText(group)
    local structuresMap = getStructuresMap();
    local s = group.Amount .. " structure" -- of type " .. table.concat(group.Structures, ", ") .. " will be added every " .. group.Interval .. " turns";
    if group.Amount ~= 1 then
        s = s .. "s";
    end
    s = s .. " of "
    if #group.Structures > 1 then
        s = s .. "either " .. structuresMap[group.Structures[1]];
        for i = 2, #group.Structures - 1 do
            s = s .. ", " .. structuresMap[group.Structures[i]];
        end
        s = s .. " or " .. structuresMap[group.Structures[#group.Structures]];
    elseif #group.Structures == 1 then
        s = s .. structuresMap[group.Structures[1]];
    else
        s = s .. "[no structure selected] "
    end
    return s .. " will be added every " .. group.Interval .. " turns";
end
