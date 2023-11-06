function dataToString(t)
    local result = {};
    for key, value in pairs(t) do
        if type(value) == type({}) then
            table.insert(result, string.format("%s=%s", key, dataToString(value)));
        elseif type(value) == type("") then
            table.insert(result, string.format("%s=\"%s\"", key, value));
            print(string.format("%s=\"%s\"", key, value));
        else
            table.insert(result, string.format("%s=%s", key, tostring(value)));
        end
    end
    return "{" .. table.concat(result, ";") .. "}";
end

function stringToData(s)
    local t = {};
    while #s > 1 do
        if string.sub(s, 1, 1) == "}" then return t, string.sub(s, 2, -1); end
        local ending = string.find(s, "=");
        local key = string.sub(s, string.find(s, "%w+"), ending - 1);
        s = string.sub(s, ending + 1, -1);
        if tonumber(key) ~= nil then
            key = tonumber(key);
        end
        local c = string.sub(s, 1, 1);
        if c == "{" then
            t[key], s = stringToData(string.sub(s, 2, -1));
            c = string.sub(s, 1, 1);
            if c == "}" then
                return t, string.sub(s, 2, -1);
            end
        else
            local start, last = string.find(s, "[^}=;]*");
            local value = string.sub(s, start, last);
            if c == "\"" then
                t[key] = value:sub(2, -2);
            elseif value == "true" then
                t[key] = true;
            elseif value == "false" then
                t[key] = false;
            else
                t[key] = tonumber(value);
            end
            c = string.sub(s, last + 1, last + 1);
            s = string.sub(s, last + 2, -1);
            if c == "}" then
                return t, s;
            end
        end
    end
    return t;
end
