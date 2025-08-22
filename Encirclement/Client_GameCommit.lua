function Client_GameCommit(game, skipCommit)
    forceCommit = forceCommit;
    if Mod.Settings.DoNotAllowDeployments and not forceCommit then
        local list = getEncircledList(game);
        if #list > 0 then
            skipCommit();
            dialog(game, list);
        end
    else
        forceCommit = false;
    end
end

function dialog(Game, list)
    Game.CreateDialog(function(rootParent, setMaxSize, setScrollable, game, close)
        local root = UI.CreateVerticalLayoutGroup(rootParent);

        local line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1).SetCenter(true);
        UI.CreateButton(line).SetText("refresh").SetColor("#00FF05").SetOnClick(function()
            close();
            dialog(game, getEncircledList(game));
        end);
        UI.CreateButton(line).SetText("Force commit").SetColor("#FF4700").SetOnClick(function()
            forceCommit = true;
            close();
            UI.Alert("Please press the commit button again to commit your orders");
        end);
        UI.CreateLabel(root).SetText("You have deployed on " .. #list .. " territor" .. aORb(#list > 1, "ies", "y") .. " that " .. aORb(#list > 1, "are", "is") .. " encircled").SetColor("#DDDDDD");
        UI.CreateLabel(root).SetText("This regards the following territories:").SetColor("#DDDDDD");
        for _, terrID in pairs(list) do
            local mapTerr = game.Map.Territories[terrID];
            UI.CreateButton(root).SetText(mapTerr.Name).SetColor("#AD7E7E").SetOnClick(function()
                game.CreateLocatorCircle(mapTerr.MiddlePointX, mapTerr.MiddlePointY);
                game.HighlightTerritories({terrID});
            end);
        end
    end);
end

function getEncircledList(game)
    local list = {};
    local p = game.Us.ID;
    for _, order in pairs(game.Orders) do
        if order.proxyType == "GameOrderDeploy" then
            local terrID = order.DeployOn;
            local isEncircled = true;
            for connID, _ in pairs(game.Map.Territories[terrID].ConnectedTo) do
                local terr = game.LatestStanding.Territories[connID];
                if terr.OwnerPlayerID == p or terr.OwnerPlayerID == WL.PlayerID.Neutral then
                    isEncircled = false;
                    break;
                end
            end
            if isEncircled then
                table.insert(list, terrID);
            end
        end
    end
    return list;
end

function aORb(predicate, a, b)
    if predicate then return a; else return b; end
end