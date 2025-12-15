require("Enums.EventEnums");

require("Events.MessageEvent");

require("Menus.EventMenus.EventMenu");
require("Menus.SlotMenu");
require("Menus.UpDownButtons");

MessageEventMenu = {};

function MessageEventMenu.ShowMenu(event)
    History.AddToHistory(MessageEventMenu.ShowMenu, event);
    UI2.DestroyWindow();
    
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));
    local inputs = {};

    EventMenu.ShowEventHeader(event, inputs, root, MessageEventMenu.SaveEvent);

    EventMenu.ShowEvent(event, inputs, root);

    UI2.CreateEmpty(root).SetPreferredHeight(5);
    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Message Event Options").SetColor(colors.TextColor);
    UI2.CreateEmpty(root).SetPreferredHeight(3);

    UI2.CreateInfoButtonLine(root, function(line)
        inputs.BroadcastMessage = UI2.CreateCheckBox(line).SetText(" ").SetIsChecked(event.BroadcastMessage or false).SetOnValueChanged(function()
            inputs.ReceiversButton.SetInteractable(not inputs.BroadcastMessage.GetIsChecked());
        end);
        UI2.CreateLabel(line).SetText("Broadcast message").SetColor(colors.TextColor);
    end, MessageEvent.Info.EventBroadcastMessage);

    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Slots: ").SetColor(colors.TextColor);
        inputs.ReceiversButton = UI2.CreateButton(line).SetText(#(event.Receivers or {}) .. " slots").SetColor(colors.Green).SetOnClick(function()
            MessageEventMenu.SaveEvent(event, inputs);
            SlotMenu.ShowMenu(event, "Receivers", function() MessageEventMenu.ShowModifyMessageEvent(event); end);
        end).SetInteractable(not inputs.BroadcastMessage.GetIsChecked());
    end, MessageEvent.Info.EventMessageReceivers);

    UI2.CreateInfoButtonLine(root, function(line)
        UI2.CreateLabel(line).SetText("Put your message together").SetColor(colors.TextColor);
    end, MessageEvent.Info.EventMessage);

    event.Message = event.Message or {""};
    inputs.Message = {};
    for _, _ in ipairs(event.Message) do
        table.insert(inputs.Message, true);
    end
    local valueClickFuncs = EventMenu.GetEventValueFunctions();
    local deleteSubPart = function(i)
        table.remove(event.Message, i);
        table.remove(inputs.Message, i);
        MessageEventMenu.SaveEvent(event, inputs);
        MessageEventMenu.ShowModifyMessageEvent(event);
    end;
    local updateOrder = function()
        MessageEventMenu.SaveEvent(event, inputs);
        MessageEventMenu.ShowModifyMessageEvent(event);
    end;

    for i, sub in ipairs(event.Message) do
        if type(sub) == "string" then
            UI2.CreateDeleteButtonLine(root, function(line)
                UpDownButtons.CreateButtons(line, inputs.Message, i, updateOrder);
                inputs.Message[i] = UI2.CreateTextInputField(line).SetText(sub).SetPlaceholderText("Type here the message").SetFlexibleWidth(9);
            end, function()
                deleteSubPart(i);
            end);
        else
            inputs.Message[i] = sub;
            UI2.CreateDeleteButtonLine(root, function(line)
                UpDownButtons.CreateButtons(line, inputs.Message, i, updateOrder);
                UI2.CreateButton(line).SetText(InjectValueEnum.GetValueTypeName(sub.Type)).SetColor(InjectValueEnum.GetValueTypeColor(sub.Type)).SetOnClick(function()
                    Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
                        UI2.NewDialog("MessageEventValue", rootParent, close);
                        setMaxSize(500, 400);
                        local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
                        MenuUtil.SelectFromList(vert, EventMenu.GenerateEventValueList(event, function(enum)
                            ---@diagnostic disable-next-line: assign-type-mismatch
                            inputs.Message[i] = EventUtil.CreateValueTable(enum);
                            updateOrder()
                        end, close), function() close(); end);
                    end);
                end);
                (valueClickFuncs[sub.Type] or void)(line, sub);
            end, function()
                deleteSubPart(i);
            end);
        end
    end

    UI2.CreateEmpty(root).SetPreferredHeight(5);

    local line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    UI2.CreateButton(line).SetText("Add text").SetColor(colors.Blue).SetOnClick(function()
        table.insert(event.Message, "");
        updateOrder()
    end);
    UI2.CreateButton(line).SetText("Add value").SetColor(colors.OrangeRed).SetOnClick(function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("MessageEventValue", rootParent, close);
            setMaxSize(500, 400);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
            MenuUtil.SelectFromList(vert, EventMenu.GenerateEventValueList(event, function(enum)
                table.insert(inputs.Message, EventUtil.CreateValueTable(enum));
                updateOrder()
            end, close), function() close(); end);
        end);
    end);
end

EventMenu.AddEventMenu(EventTypeEnum.MESSAGE_EVENT, MessageEventMenu.ShowModifyMessageEvent);

---Saves a message event
---@param event MessageEvent
---@param inputs table
function MessageEventMenu.SaveEvent(event, inputs)
    if not UI2.IsDestroyed(inputs.BroadcastMessage) then event.BroadcastMessage = inputs.BroadcastMessage.GetIsChecked(); end

    local triggerType = 0;
    for i, sub in ipairs(inputs.Message) do
        if EventUtil.IsValueTable(sub) then
            event.Message[i] = sub;
            EventUtil.SaveEventValue(event.Message[i], sub);
            triggerType = InjectValueEnum.InjectValueConstraints[sub.Type].TriggerType or triggerType;
        else
            if not UI2.IsDestroyed(sub) then event.Message[i] = sub.GetText(); end
        end
    end
    event.CompatibleTriggerType = triggerType;
    EventMenu.SaveEvent(event, inputs);
end