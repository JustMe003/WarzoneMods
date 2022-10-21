
function getDateIndexList() return {"Year", "Month", "Day", "Hours", "Minutes", "Seconds", "MilliSeconds"}; end

function getDateRestraints() return {99999999, 12, 30, 24, 60, 60, 1000} end;

function dateToTable(s)
    local list = getDateIndexList();
    local r = {};
    local i = 1;
    local buffer = "";
    local index = 1;
    while i <= string.len(s) do
        local c = string.sub(s, i, i);
        if c == "-" or c == " " or c == ":" then
            r[list[index]] = tonumber(buffer);
            buffer = "";
            index = index + 1;
        else
            buffer = buffer .. c;
        end
        i = i + 1;
    end
    r[list[index]] = tonumber(buffer);
    return r;
end

function tableToDate(t)
    return t.Year .. "-" .. addZeros("Month", t.Month) .. "-" .. addZeros("Day", t.Day) .. " " .. addZeros("Hours", t.Hours) .. ":" .. addZeros("Minutes", t.Minutes) .. ":" .. addZeros("Seconds", t.Seconds) .. ":" .. addZeros("MilliSeconds", t.MilliSeconds);
end

function addTime(t, field, i)
    local dateIndex = getDateIndexList();
    local restraint = getDateRestraints()[getTableKey(dateIndex, field)];
    t[field] = t[field] + i;
    if t[field] > restraint then
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
    if field == "MilliSeconds" then
        if i < 10 then
            return "00" .. i;
        elseif i < 100 then
            return "0" .. i;
        end
    else
        if i < 10 then
            return "0" .. i;
        end
    end
    return i;
end


function dateIsEarlier(date1, date2)
    local list = getDateIndexList();
    for _, v in pairs(list) do
        if v == "MilliSeconds" then return false; end
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
