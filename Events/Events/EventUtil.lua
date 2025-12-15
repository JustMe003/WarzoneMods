require("Enums.InjectValueEnums");

---@class Expression
---@field Operator OperatorEnum
---@field Left Expression | ValueTable
---@field Right Expression | ValueTable

---@alias OperatorEnum integer
---@alias OperatorName string

---@class ValueTable
---@field Type ValueEnum
---@field Value number?
---@field Input UIObject?

EventUtil = {};


function EventUtil.SaveEventValue(data, input)
    if data == nil then return; end
    if data.Type == InjectValueEnum.SLOT_PLAYER or data.Type == InjectValueEnum.TRIGGER_TERR_STRUCTURE_COUNT then
        data.Value = input.Value;
    elseif input.Input ~= nil then
        if not UI2.IsDestroyed(input.Input) then data.Value = input.Input.GetValue(); end
        data.Input = nil;
    end
end

function EventUtil.IsValueTable(t)
    return t.Type ~= nil and t.Type ~= InjectValueEnum.EXPRESSION;
end

function EventUtil.IsExpression(t)
    return t.Operator ~= nil and t.Type == InjectValueEnum.EXPRESSION;
end

function EventUtil.RemoveValueFromExpression(data)
    if EventUtil.IsValueTable(data) then return {}; end
    if EventUtil.IsExpression(data) then
        if EventUtil.IsExpression(data.Left) or EventUtil.IsValueTable(data.Left) then
            return data.Left;
        end
        return data.Right;
    end
    return {};
end

function EventUtil.CreateValueTable(enum)
    return { Type = enum };
end