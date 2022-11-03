require("UI");
require("TimeStamp");
Init();
colors = GetColors();

function timeSinceLastUpdate(game, field, time)
    return Mod.PlayerGameData.LastUpdate_JAD == nil or dateIsEarlier(addTime(dateToTable(Mod.PlayerGameData.LastUpdate_JAD), field, time), dateToTable(game.Game.ServerTime));
end

function sendUpdate(game, f)
    game.SendGameCustomMessage("Updating mod...", {Type="receiveUpdate", TimeStamp=game.Game.ServerTime}, function(t) f(); end);
end

function showIntroductionDialog(game, message)
    payload = {Message=message};
    createDialog(game, createIntroductionDialog);
end

function hasSeenIntroductionMessage()
    return Mod.PlayerGameData.Notifications_JAD ~= nil;
end

function playerWantsNotifications()
    return Mod.PlayerGameData.Notifications_JAD ~= nil and Mod.PlayerGameData.Notifications_JAD;
end

function createDialog(game, func)
    if hasOpenDialog_JAD == nil then
        game.CreateDialog(func);
        hasOpenDialog_JAD = true;
    end
end

function createIntroductionDialog(rootParent, setMaxSize, setScrollable, game, close)
    setMaxSize(400, 400);
    SetWindow("Introduction");
    local vert = CreateVerticalLayoutGroup(rootParent);
    CreateLabel(vert).SetText("This mod makes use of Just_A_Dutchman_'s dialog system\n\n").SetColor(colors.Ivory);
    CreateLabel(vert).SetText(payload.Message).SetColor(colors.Orange);
    CreateEmpty(vert).SetPreferredHeight(10);
    createYesNoButtons(vert, game, close);
end

function createYesNoButtons(parent, game, close)
    CreateButton(parent).SetText("Yes, I want to receive warnings and other messages from this mod").SetColor(colors.Green).SetOnClick(function() game.SendGameCustomMessage("Updating mod", {Type="showMessages", Value=true}, function(t) UI.Alert("Successfully updated the mod!\n\nIf you want to change your choice you can do this in the mod menu") end); close(); end);
    CreateButton(parent).SetText("No, I do not want to receive warnings or other messages from this mod").SetColor(colors.Red).SetOnClick(function() game.SendGameCustomMessage("Updating mod", {Type="showMessages", Value=false}, function(t) UI.Alert("Successfully updated the mod!\n\nIf you want to change your choice you can do this in the mod menu") end); close(); end);
end
