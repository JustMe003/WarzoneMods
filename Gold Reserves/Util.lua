
function getSlotIndex(s)
    local c = 0;
    for i = 1, #s do
        local b = string.byte(s, i, i);
        c = c + ((b - 64) * 26^(#s - i));
    end
    c = c - 1;
    -- print(c);
    return c;
end

function validateSlotName(s)
    if #s < 1 then return false; end
    for i = 1, #s do
        local b = string.byte(s, i, i);
        if b > 90 or b < 65 then return false; end
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

function getSlotColor(slot)
    slot = slot % getTableLength(colors);
    for _, color in pairs(colors) do
        if slot == 0 then return color; end
        slot = slot - 1;
    end
end

function getTableLength(t)
    local c = 0;
    for _, _ in pairs(t) do
        c = c + 1;
    end
    return c;
end

function getReserveText(n)
    if n < 0 then 
        return "- " .. math.abs(n);
    elseif n > 0 then
        return "+ " .. n;
    end
    return n;
end

function getReserveTextColor(n)
    if n > 0 then
        return colors.Green;
    elseif n < 0 then
        return colors["Orange Red"];
    end
    return colors.Cyan;
end