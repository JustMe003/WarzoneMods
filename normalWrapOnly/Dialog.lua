require("UI");
Init();
colors = GetColors();

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
    SetWindow("Introduction");
    local vert = CreateVerticalLayoutGroup(rootParent);
    CreateLabel(vert).SetText("This mod makes use of Just_A_Dutchman_'s dialog system\n\n").SetColor(colors.Ivory);
    CreateLabel(vert).SetText(payload.Message).SetColor(colors.Orange);
    CreateEmpty(vert).SetPreferredHeight(10);
    createYesNoButtons(vert, game);
end

function createYesNoButtons(parent, game)
    CreateButton(parent).SetText("Yes, I want to receive warnings and other messages from this mod").SetColor(colors.Ivory).SetOnClick(function() game.SendGameCustomMessage("Updating mod", {Type="showMessages", Value=true}, function(t) UI.Alert("Successfully updated the mod!\n\nIf you want to change your choice you can do this in the mod menu") end); end);
    CreateButton(parent).SetText("No, I do not want to receive warnings or other messages from this mod").SetColor(colors.Ivory).SetOnClick(function() game.SendGameCustomMessage("Updating mod", {Type="showMessages", Value=false}, function(t) UI.Alert("Successfully updated the mod!\n\nIf you want to change your choice you can do this in the mod menu") end); end);
end

function getFunction(type)
    local functions = {showMessages=savePlayerWantsNotifications};
    return functions[type];
end

function savePlayerWantsNotifications(playerID, game, payload, setReturn)
    if pd == nil then pd = {}; end
    pd.Notifications_JAD = payload.Value;
end