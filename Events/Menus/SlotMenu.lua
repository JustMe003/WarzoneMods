require("Util.Slots");

SlotMenu = {};

function SlotMenu.ShowMenu(trigger, field, returnFunc)
    UI2.DestroyWindow()
    
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1)).SetCenter(true);
    trigger[field] = trigger[field] or {};
    local slots = trigger[field];
    local reload = function()
        SlotMenu.ShowMenu(trigger, field, returnFunc);
    end;
    
    UI2.CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(returnFunc);
    UI2.CreateLabel(root).SetText("Modify slots").SetColor(colors.TextColor);

    local slotInput = UI2.CreateTextInputField(root).SetPlaceholderText("Slot name").SetPreferredWidth(300);
    UI2.CreateButton(root).SetText("Add slot").SetColor(colors.Green).SetOnClick(function()
        local slotName = string.upper(slotInput.GetText());
        if validateSlotName(slotName) then
            local slot = getSlotIndex(slotName);
            if not valueInTable(slots, slot) then
                table.insert(slots, getSlotIndex(slotName));
                SlotMenu.ShowMenu(trigger, field, returnFunc);
            else
                UI2.Alert("Slot " .. slotName .. " is already included");
            end
        else
            UI2.Alert(MenuUtil.GetInvalidSlotNameString());
        end
    end)

    UI2.CreateEmpty(root).SetPreferredHeight(10);

    table.sort(slots);
    
    if #slots > 0 then
        UI2.CreateLabel(root).SetText("Slots included:").SetColor(colors.TextColor);
        for i = #slots, 1, -3 do
            if i > 2 then
                local line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
                SlotMenu.CreateSlotButton(line, slots, i, slots[i], reload);
                UI2.CreateEmpty(line).SetMinWidth(5);
                SlotMenu.CreateSlotButton(line, slots, i - 1, slots[i - 1], reload);
                UI2.CreateEmpty(line).SetMinWidth(5);
                SlotMenu.CreateSlotButton(line, slots, i - 2, slots[i - 2], reload);
            elseif i == 2 then
                local line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
                SlotMenu.CreateSlotButton(line, slots, i, slots[i], reload);
                UI2.CreateEmpty(line).SetMinWidth(15);
                SlotMenu.CreateSlotButton(line, slots, i - 1, slots[i - 1], reload);
            elseif i == 1 then
                SlotMenu.CreateSlotButton(root, slots, i, slots[i], reload);
            end
        end
    end
end

function SlotMenu.CreateSlotButton(par, slots, index, slot, func)
    UI2.CreateButton(par).SetText(getSlotName(slot)).SetColor(MenuUtil.GetColorFromList(slot)).SetOnClick(function()
        table.remove(slots, index);
        func();
    end);
end

function SlotMenu.SetSingleSlot(line, input)
    input.Value = input.Value or 0;
    UI2.CreateEmpty(line).SetFlexibleWidth(1);
    local but = UI2.CreateButton(line).SetText(getSlotName(input.Value)).SetColor(MenuUtil.GetColorFromList(input.Value));
    but.SetOnClick(function()
        Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
            UI2.NewDialog("SetSingleSlot", rootParent, close);
            setMaxSize(300, 300);
            local vert = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
            local textField = UI2.CreateTextInputField(vert).SetText("").SetPlaceholderText("Slot name").SetPreferredWidth(250);
            local horz = UI2.CreateHorz(vert).SetFlexibleWidth(1).SetCenter(true);
            UI2.CreateButton(horz).SetText("Submit").SetColor(colors.Green).SetOnClick(function()
                local text = string.upper(textField.GetText());
                if validateSlotName(text) then
                    input.Value = getSlotIndex(text);
                    close();
                    but.SetText(getSlotName(input.Value)).SetColor(MenuUtil.GetColorFromList(input.Value));
                else
                    UI2.Alert(MenuUtil.GetInvalidSlotNameString());
                end
            end);
            UI2.CreateButton(horz).SetText("Cancel").SetColor(colors.Red).SetOnClick(function()
                close();
            end)
        end);
    end);
end
