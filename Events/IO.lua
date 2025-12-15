IO = {};
local string = string;
local pairs = pairs;
local table = table;
local type = type;
local tostring = tostring;
local print = print;
local tonumber = tonumber;

--  No more external access after this point
_ENV = {};
local T = {};


---Turns a table into a string
---@param t table
---@return string
function T.TableToString(t)
    if t == nil then return "{}"; end
    local result = {};
    local hasValues = false
    for key, value in pairs(t) do
        hasValues = true
        if type(key) == "string" then
            key = string.format("\"%s\"", string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(key, "=", "&#061"), ";", "&#059"), "\\", "\\\\"), "}", "&#125"), "{", "&#123"), "\"", "\\\""));
        end
        if type(value) == "table" then
            table.insert(result, string.format("%s=%s", key, IO.TableToString(value)));
        elseif type(value) == "string" then
            table.insert(result, string.format("%s=\"%s\"", key, string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(value, "=", "&#061"), ";", "&#059"), "\\", "\\\\"), "}", "&#125"), "{", "&#123"), "\"", "\\\"")));
        elseif type(value) == "number" or type(value) == "boolean" then
            table.insert(result, string.format("%s=%s", key, tostring(value)));
        else
            print("[IO]: Found unserializable type `" .. type(value) .. "`");
        end
    end
    if hasValues then
        return "{" .. table.concat(result, ";") .. ";}";
    else
        return "{}";
    end
end

---Turns a string into a table. ONLY pass strings that were converted using the same file to this function!
---@param s string
---@return table
function T.StringToTable(s)
    if s == nil then return {}; end
    if s:sub(1, 1) == "{" and s:sub(-1, -1) == "}" then s = s:sub(2, -2); end
    -- print(s);           -- For debug purposes when a mod crashes
    local key;
    local t = {};
    while #s > 1 do
        local c = s:gsub("[=;%s]*(.).*", "%1");
        -- print("c: " .. c, " (" .. #c .. ")");
        if #c ~= 1 then
            return t;
        end
        if c == "\"" then
            if key == nil then
                key, s = getStringValue(s)
            else
                t[key], s = getStringValue(s)
                key = nil;
            end
        elseif tonumber(c) ~= nil or c == "-" then
            if key == nil then
                key, s = getNumberValue(s);
            else
                t[key], s = getNumberValue(s);
                key = nil;
            end
        elseif c == "{" then
            if key == nil then
                print("[IO]: Wrongly formatted data: `key` was nil while finding inner table");
            else
                t[key] = IO.StringToTable(s:gsub(".-(%b{}).*", "%1"):sub(2, -2));
                s = s:gsub(".-%b{}(.*)", "%1");
                key = nil;
            end
        elseif c == "t" then
            if key == nil then
                print("[IO]: Wrongly formatted data: `key` was nil while finding `true`");
                return t;
            elseif s:gsub("[=;%s]*([true]*).*", "%1") == "true" then
                t[key] = true
                s = s:gsub("true", "", 1);
                key = nil;
            else
                print("[IO]: Wrongly formatted data: Found 't', was expecting 'true', but found '" .. s:gsub("[=;%s]*(%w*).*", "%1") .. "'");
                return t;
            end
        elseif c == "f" then
            if key == nil then
                print("[IO]: Wrongly formatted data: `key` was nil while finding `false`");
                return t;
            elseif s:gsub("[=;%s]*([false]*).*", "%1") == "false" then
                t[key] = false
                s = s:gsub("false", "", 1);
                key = nil;
            else
                print("[IO]: Wrongly formatted data: Found 'f', was expecting 'false', but found '" .. s:gsub("[=;%s]*(%w*).*", "%1") .. "'");
                return t;
            end
        else
            return t;
        end
    end
    return t;
end

---Returns the sub string between double quotation marks `"` and removes the read value from the input string
---@param s string # The input string
---@return string # The value between double quotation marks
---@return string # The rest of the input string
function getStringValue(s)
    local startKey = s:find("\"");
    s = s:sub((startKey or 1) + 1, -1);        -- remove preceding characters
    local _, endKey = s:find("\"[;=]");
    return s:sub(1, endKey - 2):gsub("\\\"", "\""):gsub("&#125", "}"):gsub("&#123", "{"):gsub("\\\\", "\\"):gsub("&#059", ";"):gsub("&#061", "="), s:sub(endKey + 0, -1);
end

---Returns the first number in the input string
---@param s string # The input string
---@return number? # The read number, can be nill
---@return string # The rest of the input string
function getNumberValue(s)
    local startValue, endValue = s:find("[%-]?%d+[%.%d+]*");
    ---@cast startValue integer
    return tonumber(s:sub(startValue, endValue)), s:sub(endValue + 1, -1);
end

IO = T;
return IO;