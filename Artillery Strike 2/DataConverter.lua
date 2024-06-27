--                      Data Converter                      --
--                 Made by:  Just_A_Dutchman_               --
--                                                          --
--                      DO NOT MODIFY!                      --
--
--      Data converter from tables to strings and vice versa.
--      Made for compatibility between mods when storing data in custom special units
--
-- HOW TO USE
--      Create a table. This table can contain number, string, boolean and even other tables as values
--      just note that functions cannot be converted. 
--      When you want to store your table into a string, call
--      DataToString() with as argument the table you want to convert into a string.
--
--      When you want to modify / read the data you stored, call StringToData() with
--      as argument the string you want to convert into a table. ONLY PROVIDE STRINGS
--      THAT WERE CREATED BY THE DataToString() FUNCTION!
--
--  WHEN TO USE
--      When you want to store data in a place where only strings can be saved. You 
--      might have a table containing multiple fields with data and you want to store
--      all of it, these functions allow you to do this
--

--  Disable warnings about undefined global variables
---@diagnostic disable: undefined-global

--  Import Section:
--  declare everything necessary here
local P = {};
DataConverter = P;
local string = string;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local pairs = pairs;
local table = table;
local type = type;
local tostring = tostring;
local print = print;
local uuid = uuid;
local tonumber = tonumber;
local error = error;
local Mod = Mod;
local rawset = rawset;



--  No more external access after this point
_ENV = {};

---@alias FormattedString string # A special, formatted string containing the contents of a table

local _VERSION_DATA_CONVERTER_JAD = "V1.1";         -- Version of the DataConverter file

local _VERSION_PATTERN = "V%d+[%.%d]+";             -- Pattern to extract the version of the encoded data

local _SIGNATURE_PATTERN = "%[" .. _VERSION_PATTERN .. "#JAD%]";        -- Pattern to extract the start and end of the encoded data

local _EMPTY_TABLE_STRING = string.format("[%s#JAD]{}[%s#JAD]", _VERSION_DATA_CONVERTER_JAD, _VERSION_DATA_CONVERTER_JAD);


---Turns a table into a string
---@param t table? # The table that will be converted to a string
---@return FormattedString # The converted string
function P.DataToString(t, m)
    Mod = m or Mod;
    -- If t == nil then return smallest possible string
    if t == nil then
        print("[DataConverter]: Table input for `DataToString` was nil");
        return _EMPTY_TABLE_STRING;
    end
    local f;
    local version;

    local metaData = getMetaData(t);        -- Extract prefix, suffix and version
    if metaData ~= nil then
        f = getFunction_TToS(metaData.Version_DataConverter_JAD);
        version = metaData.Version_DataConverter_JAD or _VERSION_DATA_CONVERTER_JAD;
    else
        -- metaData == nil, this table has not been decoded from a string so we take the latest version
        f = getFunction_TToS(_VERSION_DATA_CONVERTER_JAD);
        version = _VERSION_DATA_CONVERTER_JAD;
    end
    if f == nil then
        print("[DataConverter]: Could not find the right function to encode the table! Returning empty table");
        return _EMPTY_TABLE_STRING;
    end

    if version ~= "V0" then
        -- Check whether the root of the table only contains other tables
        local err = "";
        for k, v in pairs(t) do
            if type(v) ~= "table" then
                err = err .. "\n`" .. tostring(k) .. "`";
            end
        end
        if #err > 0 then
            error("[DataConverter]: Elements in the root of the table cannot be non-table values. The following keys contain non-table values" .. err, 2);
        end
    end

    -- Start building return string
    local s = "";
    if metaData ~= nil and metaData.Prefix_DataConverter_JAD ~= nil then
        s = s .. metaData.Prefix_DataConverter_JAD;         -- Append prefix (for compatibility)
    end
    s = string.format("%s[%s#JAD]%s[%s#JAD]", s, version, f(t), version);
    if metaData ~= nil and metaData.Suffix_DataConverter_JAD ~= nil then
        s = s .. metaData.Suffix_DataConverter_JAD;         -- Append suffix (for compatibility)
    end
    return s;
end


---Turns a string into a table. Always returns a table, even if the string is wrongly configured
---@param s FormattedString? # The string that has the convention
---@return table # The converted table
function P.StringToData(s, m)
    Mod = m or Mod;
    if s == nil then
        print("[DataConverter]: Input to `StringToData` was nil");
        return {};
    end

    -- print("[DataConverter]: Input string = `" .. s .. "`");       -- Debugging purposes

    local testForVersionZero = string.find(s, "\29%b{}\29");
    if testForVersionZero ~= nil then
        -- The data was mapped to a string using the first (V0) version
        print("[DataConverter]: Version = V0");
        f = getFunction_SToT("\29");
        local startOfData, endOfData = s:find("\29%b{}\29");
        if f ~= nil and startOfData ~= nil and endOfData ~= nil then
            local prefix = s:sub(1, startOfData - 1);
            local suffix = s:sub(endOfData + 1, -1);
            -- Get the table from the string
            local t = f(s:sub(startOfData + 1, endOfData - 1));
            -- Add the prefix and suffix if they exists
            return addMetaData(t, prefix, suffix, "V0");
        end
    else
        -- All newer versions have their version number integrated with the data
        local startOfData, endOfData = s:find(string.format("%s%%b{}%s", _SIGNATURE_PATTERN, _SIGNATURE_PATTERN));
        if startOfData ~= nil and endOfData ~= nil then
            local version = findAndReturnSubString(s:sub(startOfData, -1), _VERSION_PATTERN);
            if version ~= nil then
                -- print("[DataConverter]: Version = " .. version);
                f = getFunction_SToT(version);
                local data = string.gsub(s:sub(startOfData, endOfData), string.format("%s(%%b{})%s", _SIGNATURE_PATTERN, _SIGNATURE_PATTERN), "%1"):sub(2, -2);
                local prefix = s:sub(1, startOfData - 1);
                local suffix = s:sub(endOfData + 1, -1);
                if f ~= nil then
                    -- Get the table from the string, trim first `{` and  last `}`
                    local t = f(data);
                    t = tableValuesOnly(t);
                    return addMetaData(t, prefix, suffix, _VERSION_DATA_CONVERTER_JAD);
                end
            else
                print("[DataConverter]: Version of data conversion could not be found");
            end
        else
            print("[DataConverter]: No data could be found");
        end
    end

    return {};
end

---Tries to find the pattern in the string s. Returns the substring
---@param s string # The string in which the pattern might occur
---@param pattern string # The pattern
---@param leftOffset integer | nil # Default 0. Determines how many characters are skipped / added from the left
---@param rightOffset integer | nil # Default 0. Determines how many characters are skipped / added from the right
---@return string | nil # The sub string that was found in s using the pattern. Nil if the pattern is not in the string
function findAndReturnSubString(s, pattern, leftOffset, rightOffset)
    leftOffset = leftOffset or 0;
    rightOffset = rightOffset or 0;
    local start, ending = string.find(s, pattern);
    if start == nil or ending == nil then
        return nil;
    end
    return string.sub(s, start + leftOffset, ending + rightOffset);
end

---Add the meta data (read only) to the table
---@param t table # The input table
---@param prefix string # The prefix of the data in the original string
---@param suffix string # The suffix of the data in the original string
---@param version string # The version string
---@return table # The original table including the meta data (read only)
function addMetaData(t, prefix, suffix, version)
    local mt = getmetatable(t);
    mt.data = readOnly({
        Prefix_DataConverter_JAD = prefix,
        Suffix_DataConverter_JAD = suffix,
        Version_DataConverter_JAD = version
    });
    setmetatable(t, mt);
    return t;
end

---Returns the meta data of the table
---@param t table # The input table
function getMetaData(t)
    return (getmetatable(t) or {}).data or {};
end


---Returns the function needed to decode the string into a table
---@param version string # The version string
---@return fun(t: table) | nil # The function needed to decode the string into a table
function getFunction_SToT(version)
    local functions = {
        ["\29"] = conversionFunction_SToT_V0,
        ["V0"] = conversionFunction_SToT_V0,
        ["V1.1"] = conversionFunction_SToT_V1_1
    };
    if version == nil then
        return conversionFunction_SToT_V0;
    else
        return functions[version];
    end
end

---Returns the function needed to decode the tablelib into a string
---@param version string? # The version string
---@return fun(s: string) | nil # The function needed to decode the table2 into a string
function getFunction_TToS(version)
    local functions = {
        ["V0"] = conversionFunction_TToS_V0,
        ["V1.1"] = conversionFunction_TToS_V1_1
    };
    if version == nil then
        return conversionFunction_TToS_V1_1;
    else
        return functions[version];
    end
end

---Converts a table into a string using V1.1 standards
---@param t table? # The input table
---@return string # the converted table as a string
function conversionFunction_TToS_V1_1(t)
    if t == nil then return "{}"; end
    local result = {};
    local hasValues = false
    for key, value in pairs(t) do
        hasValues = true
        if type(key) == "string" then
            key = string.format("\"%s\"", string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(key, "=", "&#061"), ";", "&#059"), "\\", "\\\\"), "}", "&#125"), "{", "&#123"), "\"", "\\\""));
        end
        if type(value) == "table" then
            table.insert(result, string.format("%s=%s", key, conversionFunction_TToS_V1_1(includeKey(value))));
            removeKey(value);
        elseif type(value) == "string" then
            table.insert(result, string.format("%s=\"%s\"", key, string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(value, "=", "&#061"), ";", "&#059"), "\\", "\\\\"), "}", "&#125"), "{", "&#123"), "\"", "\\\"")));
        elseif type(value) == "number" or type(value) == "boolean" then
            table.insert(result, string.format("%s=%s", key, tostring(value)));
        else
            print("[DataConverter]: Found unserializable type `" .. type(value) .. "`");
        end
    end
    if hasValues then
        return "{" .. table.concat(result, ";") .. ";}";
    else
        return "{}";
    end
end

---Converts a table into a string using V0 standards
---@param t table? # The input table
---@return string # the converted table as a string
function conversionFunction_TToS_V0(t)
    if t == nil then return "\29{}\29"; end
    local result = {};
    for key, value in pairs(t) do
        if type(value) == type({}) then
            table.insert(result, string.format("%s=%s", key, conversionFunction_TToS_V0(value)));
        elseif type(value) == type("") then
            table.insert(result, string.format("%s=\"%s\"\29", key, value));
        else
            table.insert(result, string.format("%s=%s", key, tostring(value)));
        end
    end
    return "{" .. table.concat(result, ";") .. "}";
end

---Converts the table that was mapped to a string (V1.1) into a table again. In case of an error, the error will be logged and the process will stop
---@param s string # The table that was mapped to a string (V1.1)
---@return table # The output table. Can be a different table that was mapped!
function conversionFunction_SToT_V1_1(s)
    if s == nil then return {}; end
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
                print("[DataConverter]: Wrongly formatted data: `key` was nil while finding inner table");
            else
                t[key] = makeReadOnly(conversionFunction_SToT_V1_1(s:gsub(".-(%b{}).*", "%1"):sub(2, -2)));
                s = s:gsub(".-%b{}(.*)", "%1");
                key = nil;
            end
        elseif c == "t" then
            if key == nil then
                print("[DataConverter]: Wrongly formatted data: `key` was nil while finding `true`");
                return t;
            elseif s:gsub("[=;%s]*([true]*).*", "%1") == "true" then
                t[key] = true
                s = s:gsub("true", "", 1);
                key = nil;
            else
                print("[DataConverter]: Wrongly formatted data: Found 't', was expecting 'true', but found '" .. s:gsub("[=;%s]*(%w*).*", "%1") .. "'");
                return t;
            end
        elseif c == "f" then
            if key == nil then
                print("[DataConverter]: Wrongly formatted data: `key` was nil while finding `false`");
                return t;
            elseif s:gsub("[=;%s]*([false]*).*", "%1") == "false" then
                t[key] = false
                s = s:gsub("false", "", 1);
                key = nil;
            else
                print("[DataConverter]: Wrongly formatted data: Found 'f', was expecting 'false', but found '" .. s:gsub("[=;%s]*(%w*).*", "%1") .. "'");
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


function conversionFunction_SToT_V0(s)
    if s == nil then return {}; end
    local firstPar = s:find("{");
    s = s:sub(firstPar + 1, -1);
    local t = {};
    while #s > 1 do
        if s:sub(1, 1) == "}" then return t, s:sub(2, -1); end
        local ending = s:find("=");
        local key = s:sub(s:find("%w+"), ending - 1);
        s = s:sub(ending + 1, -1);
        if tonumber(key) ~= nil then
            key = tonumber(key);
        end
        local c = s:sub(1, 1);
        if key == nil then
            return t, "";
        end
        if c == "{" then
            t[key], s = conversionFunction_SToT_V0(s);
            ---@cast s string
            c = s:sub(1, 1);
            if c == "}" then
                return t, s:sub(2, -1);
            end
        else
            local start, last = s:find("[^}=;]*");
            if c == "\"" then
                local mark = string.find(s:sub(start + 1, -1), "\29");
                local value = s:sub(start + 1, mark - 1);
                t[key] = value;
                last = mark + 1;
            else
                local value = s:sub(start, last);
                if value == "true" then
                    t[key] = true;
                elseif value == "false" then
                    t[key] = false;
                else
                    t[key] = tonumber(value);
                end
            end
            c = s:sub(last + 1, last + 1);
            s = s:sub(last + 2, -1);
            if c == "}" then
                return t, s;
            end
        end
    end
    return t;
end

---Set up an injectable key. When set-up, this key allows you to write to your tables
function P.SetKey(mod)
    Mod = mod or Mod;
    if Mod == nil then
        print("[DataConverter]: `Mod` is nil", 2);
        return nil;
    end
    if Mod.Settings == nil then
        error("[DataConverter]: `Mod.Settings` is nil", 2);
    end
    local t = Mod.Settings.DataConverter or {};
    if t.Key == nil then
        t.Key = uuid();
    end
    Mod.Settings.DataConverter = t;
end

---Gets the key of the mod. Will throw an error if something is not right
---@return string?
function getKey()
    if Mod == nil then
        print("[DataConverter]: `Mod` is nil", 2);
        return nil;
    end
    if Mod.Settings == nil then
        error("[DataConverter]: `Mod.Settings` is nil", 2);
    end
    if Mod.Settings.DataConverter == nil then
        return;    
    end
    return Mod.Settings.DataConverter.Key;
end

---Makes the table include the table key
---@param t table # The input table
---@return table # The input table with a table key
function includeKey(t)
    local mt = getmetatable(t) or {};
    t.__key = mt.__key or getKey() or uuid();       -- First try to take the key in the metatable, then personal key, then random key
    return t;
end

---Removes the key from the given table
---@param t table # The input table
---@return table # The input table without the key
function removeKey(t)
    t.__key = nil;
    return t;
end

---Makes the given table read-only IF the user key and table key are not the same
---@param t table # The input table
---@return table # The input table but made read-only if the user key and the table key are not the same
function makeReadOnly(t)
    local proxy = {};
    local key = t.__key
    t.__key = nil;
    local mt = {
        __key = key;
        __index = t;
        __pairs = function(t2, k, v)
            return pairs(t);
        end
    };
    if getKey() ~= nil and key ~= getKey() then
        mt.__newindex = function(t2, k, v)
            error("[DataConverter]: You are not allowed to modify this table", 2);
        end
    end
    setmetatable(proxy, mt);
    return proxy;
end

---Makes the given table a readonly table
---@param t table # The input table
---@return table # The readonly table
function readOnly(t)
    local proxy = {};
    local mt = {       -- create metatable
        __index = t,
        __newindex = function (t2, k, v)
            error("attempt to update a read-only table: " .. k .. " is not writable");
        end,
        __pairs = function(t2, k, v)
            return pairs(t);
        end
    };
    setmetatable(proxy, mt);
    return proxy;
end

---Makes the given table only accept tables as values
---@param t table # The input table
---@return table # The input table that only accepts tables as values
function tableValuesOnly(t)
    local proxy = {};
    local mt = {       -- create metatable
        __index = t,
        __newindex = function (t2, k, v)
            if type(v) == "table" then
                local mt2 = getmetatable(t[k]);
                if t[k] ~= nil and mt2 ~= nil and getkey() ~= nil and mt2.__key ~= getKey() then
                    error("[DataConverter]: You are not allowed to modify the value on index `" .. k .. "`");
                end
                rawset(t, k, v);
            else
                error("[DataConverter]: value `" .. tostring(v) .. "` must be a table");
            end
        end,
        __pairs = function(t2, k, v)
            return pairs(t);
        end
    };
    setmetatable(proxy, mt);
    return proxy;
end

DataConverter = readOnly(DataConverter);

return DataConverter;