require("Client_PresentMenuUI")
function Client_GameRefresh(Game)
	if not refreshCalled then
        refreshCalled = true;
        game = Game;
--        numOfTerrClicks = 0;
--        lastTerrClicked = -1;
        numOfBonusClicks = 0;
        lastBonusClicked = -1;
--        UI.InterceptNextTerritoryClick(handleTerritoryClick);
        UI.InterceptNextBonusLinkClick(handleBonusLinkClick);
    end
end

function handleTerritoryClick(terrDetails)
    if terrDetails ~= nil then
        print(terrDetails.Name);
        if terrDetails.ID == lastTerrClicked then
            numOfTerrClicks = numOfTerrClicks + 1;
        else
            numOfTerrClicks = 1;
            lastTerrClicked = terrDetails.ID;
        end
        if numOfTerrClicks == 3 then
            numOfTerrClicks = 0;
            if not UI.IsDestroyed(vert) then
                Close();
            end
            game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, 1); end);
        end
    end
    UI.InterceptNextTerritoryClick(handleTerritoryClick);
    return WL.CancelClickIntercept;
end

function handleBonusLinkClick(bonusDetails)
    if bonusDetails ~= nil then 
        print(bonusDetails.Name);
        if bonusDetails.ID == lastBonusClicked then
            numOfBonusClicks = numOfBonusClicks + 1;
        else
            numOfBonusClicks = 1;
            lastBonusClicked = bonusDetails.ID;
        end
        if numOfBonusClicks == 3 then
            numOfBonusClicks = 0;
            if (UI.IsDestroyed ~= nil and not UI.IsDestroyed(vert)) then
                Close();
            end
            game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, 2); end);
        end
    end
    UI.InterceptNextBonusLinkClick(handleBonusLinkClick);
    return WL.CancelClickIntercept;
end