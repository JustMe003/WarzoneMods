UpDownButtons = {};

function UpDownButtons.CreateButtons(line, list, index, final)
    UI2.CreateButton(line).SetText("^").SetColor(colors.RoyalBlue).SetOnClick(function()
        local this = list[index];
        if index == 1 then
            list[index] = list[#list];
            list[#list] = this;
        else
            list[index] = list[index - 1];
            list[index - 1] = this;
        end
        final();
    end).SetInteractable(#list > 1);
    UI2.CreateButton(line).SetText("v").SetColor(colors.RoyalBlue).SetOnClick(function()
        local this = list[index];
        if #list == index then
            list[index] = list[1];
            list[1] = this;
        else
            list[index] = list[index + 1];
            list[index + 1] = this;
        end
        final();
    end).SetInteractable(#list > 1);
end