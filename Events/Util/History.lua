local History_JAD = {};
local HistoryIndex_JAD = 0;

---@class History
---@field AddToHistory fun(func: fun(), ...: any)
---@field GetPreviousWindow fun()
---@field GetNextWindow fun()
---@field GetHasNextWindow fun(): boolean
---@field GetHasPreviousWindow fun(): boolean
---@field GetFirstWindow fun()

History = {};

local compareTables_JAD = function(t1, t2)
    if t1 == t2 then return true; end
    if type(t1) == "table" and type(t2) == "table" then
        for i, v in pairs(t1) do
            print(type(v), type(t2[i]), v == t2[i]);
            if type(v) ~= type(t2[i]) or v ~= t2[i] then
                return false;
            end
        end
    else 
        return false;
    end
    return true;
end

---Adds a new entry to the history
---@param func fun() # Zero argument callback function that will be called if the user wants to go back a page
---```
--- function subMenu(parent)
---     -- We want to add this function to the history
---     -- This allows the user to back-track when navigating the UI
---     AddToHistory(function()
---         subMenu(parent);
---     end);
--- end
---```
function History.AddToHistory(func, ...)
    if HistoryIndex_JAD > 0 then
        print(func == History_JAD[HistoryIndex_JAD], compareTables_JAD(History_JAD[HistoryIndex_JAD], {...}));
        if func == History_JAD[HistoryIndex_JAD] and compareTables_JAD(History_JAD[HistoryIndex_JAD], {...}) then
            return;
        end
    end
    HistoryIndex_JAD = HistoryIndex_JAD + 1;
    History_JAD[HistoryIndex_JAD] = {
        Function = func,
        Arguments = {...}
    };
    History.PrintHistoryTable();
end

function History.PrintHistoryTable()
    for i, h in ipairs(History_JAD) do
        print("Index: " .. i);
        print("\tFunc: " .. tostring(h.Function));
        print("\tArgs: " .. tostring(h.Arguments));
        if type(table.unpack(h.Arguments)) == "table" then
            for k, v in pairs(h.Arguments) do
                print("\t", k, v);
            end
        end
    end
    print("History Index: " .. HistoryIndex_JAD);
end

---Call the previous entry in the history
---```
--- -- This button will, when interacted with, invoke the previous entry in the history
--- CreateButton(root).SetText("Go back").SetOnClick(GetPreviousWindow);
---```
function History.GetPreviousWindow()
    HistoryIndex_JAD = HistoryIndex_JAD - 1;
    History_JAD[HistoryIndex_JAD].Function(table.unpack(History_JAD[HistoryIndex_JAD].Arguments));
end

---Call the next entry in the history
------```
--- -- This button will, when interacted with, invoke the next entry in the history
--- CreateButton(root).SetText("Go next").SetOnClick(GetNextWindow);
---```
function History.GetNextWindow()
    HistoryIndex_JAD = HistoryIndex_JAD + 1;
    History_JAD[HistoryIndex_JAD].Function(table.unpack(History_JAD[HistoryIndex_JAD].Arguments));
end

---Returns whether the history contains a next window
---@return boolean # True if the history has a next window, false otherwise
function History.GetHasNextWindow()
    return HistoryIndex_JAD ~= #History_JAD;
end

---Returns whether the history contains a previous window
---@return boolean # True if the history has a previous window, false otherwise
function History.GetHasPreviousWindow()
    return HistoryIndex_JAD > 1;
end

---Invokes the first entry in the history and resets it
---```
--- --
--- CreateButton(root).SetText("Home").SetOnClick(GetFirstWindow);
---```
function History.GetFirstWindow()
    HistoryIndex_JAD = 0;
    local t = History_JAD[1];    
    History_JAD = {};
    t.Function(table.unpack(t.Arguments));
end
