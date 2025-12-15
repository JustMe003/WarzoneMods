require("Enums.OperatorEnums");
require("Enums.InjectValueEnums");

require("Menus.EventMenus.EventMenu");

ExpressionMenu = {};

function ExpressionMenu.ShowMenu(root, event, data, inputs, parField, reloadEvent)
    data[parField] = data[parField] or {};
    inputs[parField] = data[parField];
    local valueClickFuncs = EventMenu.GetEventValueFunctions();
    local pickValue = function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("ModifyExpression", rootParent, close);
            setMaxSize(500, 400);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
            MenuUtil.SelectFromList(vert, EventMenu.GenerateEventValueList(event, function(type)
                if type == InjectValueEnum.EXPRESSION then
                    inputs[parField] = ExpressionMenu.CreateExpression();
                else
                    inputs[parField] = EventUtil.CreateValueTable(type);
                end
                reloadEvent();
            end, close), function() close(); end);
        end);
    end;
    if EventUtil.IsValueTable(data[parField]) then
        UI2.CreateDeleteButtonLine(root, function(line)
            UI2.CreateButton(line).SetText(InjectValueEnum.GetValueTypeName(data[parField].Type)).SetColor(InjectValueEnum.GetValueTypeColor(data[parField].Type)).SetOnClick(pickValue);
            (valueClickFuncs[data[parField].Type] or void)(line, inputs[parField]);
        end, function()
            inputs[parField] = EventUtil.RemoveValueFromExpression(data[parField]);
            reloadEvent();
        end)
    elseif EventUtil.IsExpression(data[parField]) then
        local operatorFunc = function()
            Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
                UI2.NewDialog("ModifyExpression", rootParent, close);
                setMaxSize(500, 400);
                local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
                MenuUtil.SelectFromList(vert, ExpressionMenu.GenerateOperatorList(function(type)
                    data[parField].Operator = type;
                    reloadEvent();
                    close();
                end), function() close(); end);
            end)
        end;

        local vert = UI2.CreateVert(UI2.CreateButton(root).SetFlexibleWidth(1).SetText(" ").SetColor(colors.Amazon).SetInteractable(false)).SetFlexibleWidth(1);

        ExpressionMenu.ShowMenu(vert, event, data[parField], inputs[parField], "Left", reloadEvent);

        if data[parField].Operator == 0 then
            UI2.CreateDeleteButtonLine(vert, function(line)
                UI2.CreateButton(UI2.CreateHorz(line).SetCenter(true).SetFlexibleWidth(1)).SetText("Select operator").SetColor(colors.Yellow).SetOnClick(operatorFunc)
            end, function()
                inputs[parField] = EventUtil.RemoveValueFromExpression(data[parField]);
                reloadEvent();
            end);
        else
            UI2.CreateDeleteButtonLine(vert, function(line)
                UI2.CreateButton(UI2.CreateHorz(line).SetCenter(true).SetFlexibleWidth(1)).SetText(ExpressionMenu.GetOperatorName(data[parField].Operator, 15)).SetColor(MenuUtil.GetColorFromList(data[parField].Operator)).SetOnClick(operatorFunc);
            end, function()
                inputs[parField] = EventUtil.RemoveValueFromExpression(data[parField]);
                reloadEvent();
            end);
        end

        ExpressionMenu.ShowMenu(vert, event, data[parField], inputs[parField], "Right", reloadEvent);
    else
        UI2.CreateButton(root).SetText("Add expression").SetColor(colors.Blue).SetOnClick(pickValue);
    end
end

---comment
---@param data any
---@param input any
---@return any
function ExpressionMenu.SaveExpression(data, input)
    if EventUtil.IsValueTable(input) then
        data = input;
        EventUtil.SaveEventValue(data, input);
        return data;
    elseif EventUtil.IsExpression(input) then
        return {
            Type = InjectValueEnum.EXPRESSION;
            Operator = input.Operator;
            Left = ExpressionMenu.SaveExpression((data or {}).Left, input.Left);
            Right = ExpressionMenu.SaveExpression((data or {}).Right, input.Right);
        };
    else
        return {};
    end
end

function ExpressionMenu.GetTriggerTypeFromExpression(data)
    if EventUtil.IsValueTable(data) then
        return InjectValueEnum.InjectValueConstraints[data.Type].TriggerType or 0;
    elseif EventUtil.IsExpression(data) then
        local left = ExpressionMenu.GetTriggerTypeFromExpression(data.Left);
        local right = ExpressionMenu.GetTriggerTypeFromExpression(data.Right);
        if left > 0 then
            return left;
        else
            return right;
        end
    end
    return 0;
end

function ExpressionMenu.GenerateOperatorList(selectFun)
    return {
        {
            Name = "+",
            Action = function()
                selectFun(OperatorEnum.ADDITION);
            end,
            Info = OperatorEnum.Info.OperatorAddition
        },
        {
            Name = "-",
            Action = function()
                selectFun(OperatorEnum.MINUS);
            end,
            Info = OperatorEnum.Info.OperatorMinus
        },
        {
            Name = "x",
            Action = function()
                selectFun(OperatorEnum.MULTIPLICATION);
            end,
            Info = OperatorEnum.Info.OperatorMultiplication
        },
        {
            Name = "/",
            Action = function()
                selectFun(OperatorEnum.DIVISION);
            end,
            Info = OperatorEnum.Info.OperatorDivision
        },
        {
            Name = "%",
            Action = function()
                selectFun(OperatorEnum.MODULUS);
            end,
            Info = OperatorEnum.Info.OperatorModulus
        }
    }
end

function ExpressionMenu.GetOperatorName(type, rep)
    local t = {
        [OperatorEnum.ADDITION] = "+",
        [OperatorEnum.MINUS] = "-",
        [OperatorEnum.MULTIPLICATION] = "x",
        [OperatorEnum.DIVISION] = "/",
        [OperatorEnum.MODULUS] = "%"
    }
    return t[type];
end

function ExpressionMenu.CreateExpression()
    return {
        Type = InjectValueEnum.EXPRESSION,
        Operator = 0,
        Left = {},
        Right = {},
    };
end