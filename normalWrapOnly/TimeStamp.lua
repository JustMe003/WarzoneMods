
function getDateIndexList() return {"Year", "Month", "Day", "Hours", "Minutes", "Seconds"}; end

function getDateRestraints() return {Hours=24, Minutes=60, Seconds=60} end;

function dateToTable(s)
    local list = getDateIndexList();
    local r = {};
    for i = 1, 6 do
        local en = string.find(s, "[-: ]");
        if en == nil then break; end
        local part = string.sub(s, 1, en - 1);
        r[list[i]] = part;
        s = string.sub(s, en + 1);
    end
    return r;
end

function tableToDate(t)
    return t.Year .. "-" .. addZeros("Month", t.Month) .. "-" .. addZeros("Day", t.Day) .. " " .. addZeros("Hours", t.Hours) .. ":" .. addZeros("Minutes", t.Minutes) .. ":" .. addZeros("Seconds", t.Seconds);
end

function addTime(t, field, i)
    local dateIndex = getDateIndexList();
    local restraint = getDateRestraints()[field];
    t[field] = t[field] + i;
    if restraint ~= nil and t[field] > restraint then
        t[field] = t[field] - restraint;
        addTime(t, dateIndex[getTableKey(dateIndex, field) - 1], 1);
    end
    return t;
end

function getTableKey(t, value)
    for i, v in pairs(t) do
        if value == v then return i; end
    end
end

function addZeros(field, i)
    if i < 10 then
        return "0" .. i;
    end
    return i;
end


function dateIsEarlier(date1, date2)
    local list = getDateIndexList();
    for _, v in pairs(list) do
        if date1[v] ~= date2[v] then
            if date1[v] < date2[v] then
                return true;
            else
                return false;
            end
        end
    end
    return false;
end
