
function getSlotIndex(s)
    local c = 0;
	s = string.upper(s);
    for i = 1, #s do
        local b = string.byte(s, i, i);
        c = c + ((b - 64) * 26^(#s - i));
    end
    c = c - 1;
    return c;
end

function validateSlotName(s)
    if #s < 1 then return false; end
    for i = 1, #s do
        local b = string.byte(s, i, i);
        if not ((b < 91 and b > 64) or (b < 123 and b > 96)) then return false; end
    end
    return true;
end

function getSlotName(slot)
	local s = "";
	slot = slot + 1;
    while slot > 0 do
        local n = slot % 26;
        if n == 0 then
            -- slot % 26 == 26
            n = 26;
        end
        slot = (slot - n) / 26;
        s = string.char(n + 64) .. s;
    end
    return "Slot " .. s;
end

function getColorFromList(n)
	if not n then return "#FFFFFF"; end
    n = n % getTableLength(colors);
    for _, color in pairs(colors) do
        if n == 0 then return color; end
        n = n - 1;
    end
end

function getTableLength(t)
	local c = 0;
	for i, _ in pairs(t) do
		c = c + 1;
	end
	return c;
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

function tableIsEmpty(t)
	for _, _ in pairs(t) do return false; end
	return true;
end

function valueInTable(t, v)
	for i, v2 in pairs(t) do
		if v == v2 then return true; end
	end
	return false;
end

function compareCardName(n1, n2)
    return string.lower(n1) == string.lower(n2);
end

function getPosNegColor(n)
	if n < 0 then return colors.OrangeRed; else return colors.Green; end
end