require("Util");

---Client_GameRefresh hook
---@param game GameClientHook
function Client_GameRefresh(game)
    if Refreshed == nil then
        Refreshed = true;
        
        game.CreateDialog(function(par, _, _, game2, close)
            require("UI");
            local root = UI2.CreateVert(par);
            ShowPage(root, game.LatestStanding);
        end);
    end
end

function ShowPage(par, t, prev)
    UI2.DestroyWindow();
    local root = UI2.CreateWindow(UI2.CreateVert(par));

    UI2.CreateButton(root).SetColor(UI2.Colors.SubmitButton).SetText("Back").SetOnClick(prev or Void).SetInteractable(type(prev) == "function");

    local tmp;
    for i, _ in pairs(t) do
        tmp = i;
    end
    
    if type(tmp) == "string" and tmp == "__proxyID" then
        for _, v in pairs(t.readableKeys) do
            local line = UI2.CreateHorz(root);
            UI2.CreateLabel(line).SetText(v);
            UI2.CreateEmpty(line).SetMinWidth(10);
            if type(t[v]) == "table" then
                UI2.CreateButton(line).SetText("Table").SetColor(UI2.Colors.TyrianPurple).SetOnClick(function()
                    ShowPage(par, t[v], function()
                        ShowPage(par, t, prev);
                    end);
                end);
            else
                UI2.CreateLabel(line).SetText(tostring(t[v]));
            end
        end
    else
        for i, v in pairs(t) do
            local line = UI2.CreateHorz(root);
            UI2.CreateLabel(line).SetText(i);
            UI2.CreateEmpty(line).SetMinWidth(10);
            if type(v) == "table" then
                UI2.CreateButton(line).SetText("Table").SetColor(UI2.Colors.TyrianPurple).SetOnClick(function()
                    ShowPage(par, v, function()
                        ShowPage(par, t, prev);
                    end);
                end);
            else
                UI2.CreateLabel(line).SetText(tostring(v));
            end
        end
    end
end