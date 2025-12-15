---Function that always returns true
---@param ... any
---@return true
function True(...)
    return true;
end

---Function that does nothing
---@param ... any
function void(...)

end

---Returns a string with all occurances of `orig` replaced by `new`
---@param str string # The original string
---@param orig string # The original sub string
---@param new string # The new sub string
---@return string # The string with all `orig` occurances replaced by `new`
function replaceSubString(str, orig, new)
    local res = string.gsub(str, orig, new);
    return res;
end

---Rounds `n` by `dec` decimals
---@param n number # The number to round
---@param dec number # The number of decimals to round `n`
---@return number # n rounded by `dec` decimals
function round(n, dec)
    local m = 10 ^ dec
    n = n * (m);
    return math.floor(n + 0.5) / m;
end

---Returns the length of the table
---@param t table<any, any> | nil # The table to count the elements
---@return number # The number of elements in the table, or 0 if passed nil
function getTableLength(t)
    local c = 0;
    for _, _ in pairs(t or {}) do
        c = c + 1;
    end
    return c;
end

---Checks whether `v` exists in table `t`
---@param t table # The table to search
---@param v any # The value to find
---@return boolean # True if the value is found, false otherwise
function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end

---Returns the highest ID in the list
---@param list table<any, table>
---@return integer
function getHighestID(list)
    local id = 0;
    for _, t in pairs(list) do
        id = math.max(id, t.ID);
    end
    return id;
end

function getReadableString(s)
    local ret = "";
    local A, Z = string.byte("A", 1, 1), string.byte("Z", 1, 1);
    local first = true;
    for i = 1, #s do
        local c = s:byte(i, i);
        if c >= A and c <= Z then
            if not first then
                ret = ret .. " ";
            end
            first = false;
            ret = ret .. string.char(c);
        else
            ret = ret .. string.char(c);
        end
    end
    return ret;
end

function appendTable(t1, t2)
    for _, v in pairs(t2) do
        table.insert(t1, v);
    end
    return t1;
end

function mergeTables(t1, t2)
    for i, v in pairs(t2) do
        t1[i] = v;
    end
    return t1;
end


function removeEmptyTables(t)
    for key, value in pairs(t) do
        if type(value) == "table" then
            if getTableLength(value) == 0 then
                t[key] = nil;
            else
                removeEmptyTables(value);
            end
        end
    end
end

function printTable(t, s)
    s = s or "";
    for k, v in pairs(t) do
        print(s .. k .. " = " .. tostring(v));
        if type(v) == "table" then
            printTable(v, s .. "  ");
        end
    end
end