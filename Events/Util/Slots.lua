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