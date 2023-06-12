require("Client_PresentMenuUI")
function Client_GameRefresh(game)
	if not refreshCalled then
        refreshCalled = true;
        numOfTerrClicks = 0;
        lastTerrClicked = -1;
        numOfBonusClicks = 0;
        lastBonusClicked = -1;
        UI.InterceptNextTerritoryClick(handleTerritoryClick);
        UI.InterceptNextBonusLinkClick(handleBonusLinkClick);
    end
end

function handleTerritoryClick(terrDetails)
    if terrDetails ~= nil then 
        if terrDetails.ID == lastTerrClicked then
            numOfTerrClicks = numOfTerrClicks + 1;
        else
            numOfTerrClicks = 1;
            lastTerrClicked = terrDetails.ID;
        end
        if numOfTerrClicks == 3 then
            numOfTerrClicks = 0;
            -- open window with territory details
        end
    end
    return WL.CancelClickIntercept;
end

function handleBonusLinkClick(bonusDetails)
    if terrDetails ~= nil then 
        if terrDetails.ID == lastBonusClicked then
            numOfBonusClicks = numOfBonusClicks + 1;
        else
            numOfBonusClicks = 1;
            lastBonusClicked = terrDetails.ID;
        end
        if numOfBonusClicks == 3 then
            numOfBonusClicks = 0;
            -- open window with territory details
        end
    end
    return WL.CancelClickIntercept;
end