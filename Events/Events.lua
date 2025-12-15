---@class UTIL # Contains enums
---@field InjectValues table<ValueName, ValueEnum>
---@field InjectValuesConstraints table<ValueEnum, InjectValueConstraint>
---@field InjectValuesMetaData table<ValueEnum, MetaData>

---@alias TriggerTypeName string
---@alias EventTypeName string
---@alias ValueName string

---@alias TriggerTypeEnum integer
---@alias EventTypeEnum integer
---@alias ValueEnum integer

---@class MetaData
---@field Color string # String of format "#XXXXXX", with X being a hex value
---@field Name string # The name of the type
---@field Info string # The info text of the type

---@class MinMaxObject # An object that has the fields Minimum and Maximum
---@field Minimum integer? # The minimum
---@field Maximum integer? # The maximum


---@alias EventID integer

---@class ListItem
---@field Name string # The name of the item
---@field Action fun() # The action that is executed when the item is chosen
---@field Info string # The extra added information of the item

---@class INFO # Struct containing all the additional information text
---@field CooldownCondition string # Cooldown condition
---@field ChanceCondition string # Chance condition
---@field MinimumNumberOfArmiesCondition string # Minimum number of armies condition
---@field MaximumNumberOfArmiesCondition string # Maximum number of armies condition

---@class InjectValueConstraint
---@field EventType integer[] | nil
---@field TriggerType integer[] | nil


---@class WarningObject
---@field Severity WarningSeverityEnum
---@field Warning string

---@enum WarningSeverityEnum
---| 'Error'
---| 'Severe'
---| 'Light'

---@alias WarningSeverityValue integer


---Returns the minimum and maximum info text of the option
---@param field "Structures" | "StructuresChanges" # Name of the field
---@return table<string, string> # Table with both min and max info string
function getStructuresInfoText(field)
    if field == "Structures" then
        return {
            Minimum = INFO.MinimumStructuresOnTerritoryString;
            Maximum = INFO.MaximumStructuresOnTerritoryString;
        };
    else
        return {
            Minimum = INFO.MinimumStructuresChangeString;
            Maximum = INFO.MaximumStructuresChangeString;
        };
    end
end

---Removes a field from a trigger
---@param trigger Trigger
---@param field string
function removeFieldFromTrigger(trigger, field)
    trigger[field] = nil;
end

function evaluateEvent(event)
    local t = {
        [UTIL.EventTypes.MessageEvent] = evaluateMessageEvent,
        [UTIL.EventTypes.SetOwnerEvent] = evaluateSetOwnerEvent,
        [UTIL.EventTypes.AddArmiesEvent] = evaluateAddArmiesEvent,
    }
    return t[event.Type](event);
end

function evaluateMessageEvent(event)
    local l = {};
    if #event.Message == 0 then
        table.insert(l, createWarning(UTIL.WarningSeverities.Error, "The message of a message event must contain at least 1 part"));
    end
    for i, v in pairs(event.Message) do
        if type(v) == "string" then
            if #v == 0 then
                createWarning(UTIL.WarningSeverities.Light, "Message part " .. i .. " is an empty string");
            end
        elseif type(v) == "table" then
            local warn = evaluateValueTable(v);
            if warn then
                table.insert(l, "Message part " .. i .. ": " .. warn);
            end
        end
    end
    return l;
end

function evaluateSetOwnerEvent(event)
    local warn = evaluateValueTable(event.NewOwner);
    if warn then return {warn}; end
    return {};
end

function evaluateAddArmiesEvent(event)
    local l = {};
    evaluateExpression(event.Addition, l, event.CompatibleTriggerType);
    return l;
end

function evaluateExpression(expr, list, triggerType)
    if EventUtil.IsExpression(expr) then
        evaluateExpression(expr.Left, list, triggerType);
        evaluateExpression(expr.Right, list, triggerType);
    else
        local warn = evaluateValueTable(expr);
        if warn then
            table.insert(list, warn);
        end
        evaluateCompatibleTriggerTypes(list, triggerType, expr.Type);
    end
end

function evaluateValueTable(t)
    if t.Type == 0 then
        return createWarning(UTIL.WarningSeverities.Severe, "No value was assigned");
    end
end

function evaluateCompatibleTriggerTypes(list, current, new)
    if current == 0 or not (UTIL.InjectValuesConstraints[new].TriggerType and UTIL.InjectValuesConstraints[new].TriggerType == current) then
        table.insert(list, createWarning(UTIL.WarningSeverities.Error, "2 different compatible trigger types found, there can only be one: " .. InjectValueEnum.GetValueTypeName(current) .. " and " .. InjectValueEnum.GetValueTypeName(new)));
    end
end

---Creates a warning
---@param level WarningSeverityValue
---@param message string
---@return WarningObject
function createWarning(level, message)
    return {
        Severity = level,
        Message = message
    }
end

