require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    Init(rootParent);
    root = GetRoot();
    colors = GetColors();
    Game = game;
    Close = close;
    setMaxSize(400, 300);

    showMain();
end

function showMain()
    DestroyWindow();
    SetWindow("Main");

    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Created By: ").SetColor(colors.TextColor);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
    CreateEmpty(line).SetFlexibleWidth(0.5);
    CreateLabel(line).SetText("HangFire").SetColor(colors["Light Blue"]);

    CreateEmpty(root).SetPreferredHeight(10);
    
    CreateLabel(root).SetText("Be careful! These lands might be filled with a nasty thing... Of course I'm talking about landmines! Only the most observant players can spot their otherwise unavoidable doom...").SetColor(colors.Tan);
    
    CreateEmpty(root).SetPreferredHeight(10);

    CreateLabel(root).SetText("Landmines can be spotted. When you have a suspicion or are certain of yourself, you can take the chance of spotting it. If you are right, the landmine will be made visible when the turn advances and nothing bad happens. If you are wrong however, you are not allowed to spot any other landmines for " .. Mod.Settings.GuessCooldown .. " turns...");
    CreateButton(root).SetText("Yes, I am certain!").SetColor(colors.Green).SetOnClick(clickTerr).SetInteractable(Mod.PlayerGameData == nil or Mod.PlayerGameData.GuessCooldown == nil or Mod.PlayerGameData.GuessCooldown < Game.Game.TurnNumber);
end

function clickTerr()
    DestroyWindow();
    SetWindow("pickTerr");

    CreateLabel(root).SetText("Now click the territory you want to reveal. Note that once you have click a territory, there is no way back...").SetColor(colors["Orange Red"]);

    CreateEmpty(root).SetPreferredHeight(10);
    CreateButton(root).SetText("Cancel").SetColor(colors.Red).SetOnClick(function() Close(); end);

    UI.InterceptNextTerritoryClick(terrPicked);
end

function terrPicked(terrDetails)
    if terrDetails == nil then return WL.CancelClickIntercept; end
    if Game.LatestStanding.Territories[terrDetails.ID].FogLevel > WL.StandingFogLevel.Visible then
        UI.Alert("You can only pick territories that you can fully see");
        clickTerr();
        return;
    end
    Game.SendGameCustomMessage("Sending guess...", {Territory = terrDetails.ID}, function(t) successWindow(t); end);
end

function successWindow(t)
    DestroyWindow();
    SetWindow("success");
    
    CreateLabel(root).SetText(t.Text).SetColor(colors[t.Color]);
    
    if t.Success then
        CreateButton(root).SetText("Take another guess").SetColor(colors.Green).SetOnClick(clickTerr);
    else
        CreateButton(root).SetText("Close").SetColor(colors.Red).SetOnClick(function() Close(); end);
    end
end
