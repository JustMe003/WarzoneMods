ConfirmMenu = {};

function ConfirmMenu.CreateConfirmPage(text, func)
    Game.CreateDialog(function(rootParent, setMaxSize, _, _, close)
        UI2.NewDialog("ConfirmDialog", rootParent, close);
        local root = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
        UI2.CreateLabel(root).SetText(text).SetColor(colors.TextColor);

        local line = UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true);
        UI2.CreateButton(line).SetText("Yes").SetColor(colors.Green).SetOnClick(function()
            func();
            close();
        end);
        UI2.CreateButton(line).SetText("No").SetColor(colors.Red).SetOnClick(function()
            close();
        end)
    end);
end