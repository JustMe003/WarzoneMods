require("Annotations");

---Adds an order in the given order list. The order must have a OccursInPhase value and should only be called from Client hooks
---@param list GameOrder[] # The order list of the player. Make sure you give it a copy of Game.Orders
---@param newOrder GameOrder # The order that will be added to the order list
function addOrderInOrderlist(list, newOrder)
    local index = 0;
    for i, order in pairs(list) do
        if order.OccursInPhase ~= nil and order.OccursInPhase > newOrder.OccursInPhase then
            index = i;
            break;
        end
    end
    if index == 0 then index = #list + 1; end
    table.insert(list, index, newOrder);
end

---Returns the amount of CustomSpecialUnits with the same name as the passed string are in the armies object
---@param armies Armies # The Armies object
---@param unitName string # The name of the unit that you want to find
---@return integer # The amount of units with the same name as the passed string that are in this armies object
function countUnit(armies, unitName)
    local ret = 0;
    for _, sp in ipairs(armies.SpecialUnits) do
        -- Since we check whether the proxyType equals 'CustomSpecialUnit', we now for sure that `Name` should exist
        ---@diagnostic disable-next-line: undefined-field
        if sp.proxyType == "CustomSpecialUnit" and sp.Name ~= nil and sp.Name == unitName then
            ret = ret + 1;
        end
    end
    return ret;
end

---Function that checks whether a value is in the given table
---@param t table # The table in which you want to search for the value
---@param v any # The value that has to be searched for
---@return boolean # True if the value is in the table, false otherwise
function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end