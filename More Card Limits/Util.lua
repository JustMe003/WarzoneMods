require("Docs");

MOD_NAME = "More Card Limits"

---Returns the name of the card
---@param cardID number|string
---@return string
function GetCardName(cardID)
    if type(cardID) == "number" then
        for name, id in pairs(WL.CardID) do
            if cardID == id then
                return name;
            end
        end
        return "No name found!";
    else
        return cardID;
    end
end

---Returns the color that appears at index n
---@param card number|string
---@return string
function GetCardColor(card)
    if type(card) == "number" then
        local i = 1;
        for _, color in pairs(UI2.Colors) do
            if i == card then
                return color;
            end
            i = i + 1;
        end
        return "#DDDDDD";
    else
        return UI2.Colors.HelpButtonColor;
    end
end

---Returns whether the passed table is empty
---@param t table
---@return boolean
function TableIsEmpty(t)
    for _, _ in pairs(t) do
        return false;
    end
    return true;
end

---Returns the size of the table
---@param t table
---@return integer
function GetTableSize(t)
    local c = 0;
    for _, _ in pairs(t) do
        c = c + 1;
    end
    return c;
end

---Creates a horizontal stacking object with indentation
---@param root UIObject
---@param indent integer?
---@return UIObject
function CreateIndentedLine(root, indent)
    indent = indent or 20;
    local line = UI2.CreateHorz(root);
    UI2.CreateEmpty(line).SetMinWidth(indent);
    return line;
end

---Returns the TeamID or PlayerID
---@param p GamePlayer
---@return TeamID | PlayerID
function GetTeamOrPlayerID(p)
    if p.Team ~= -1 then return p.Team; end
    return p.ID;
end

---Returns true if the passed value is present in the passed table
---@param t table
---@param v any
---@return boolean
function ValueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end

---Prints the given table
---@param t table
---@param s string?
function PrintTable(t, s)
    s = s or "";
    for i, v in pairs(t) do
        print(string.format("%s%s: %s", s, tostring(i), tostring(v)));
        if type(v) == "table" then
            PrintTable(v, s .. "  ");
        end
    end
end

---Concats the table elements into a correct, english summation
---@param t table
---@return string
function ConcatTable(t)
    local size = GetTableSize(t);
    
    if size == 1 then
        for _, v in pairs(t) do
            return tostring(v);
        end
    end

    local str = "";
    local c = 1;
    for _, v in pairs(t) do
        str = str .. tostring(v);
        c = c + 1;
        if c == size then
            str = str .. " and ";
        elseif c < size then
            str = str .. ", ";
        end
    end
    return str;
end

---Returns the plural of the word if the passed number if not 1
---@param n number
---@param s string
---@return string
function ConditionalPlural(n, s)
    if n == 1 then return s; else return Plural(s); end
end

---Returns the plural of the passed word. Does not take special cases into account
---@param s string
---@return string
function Plural(s)
    local lastChar = string.sub(s, -1, -1);
    local LastTwoChars = string.sub(s, -2, -1);

    if lastChar == "s" or lastChar == "z" or lastChar == "x" or LastTwoChars == "sh" or LastTwoChars == "ch" then
        return s .. "es";
    elseif lastChar == "y" then
        local c = string.sub(LastTwoChars, 1, 1);
        if c == "a" or c == "e" or c == "i" or c == "o" or c == "u" then
            return s .. "s";
        else
            return string.sub(s, 1, -2) .. "ies";
        end
    elseif lastChar == "f" then
        return string.sub(s, 1, -2) .. "ves";
    elseif LastTwoChars == "fe" then
        return string.sub(s, 1, -3) .. "ves";
    else 
        return s .. "s";
    end
end

function Void(...)

end