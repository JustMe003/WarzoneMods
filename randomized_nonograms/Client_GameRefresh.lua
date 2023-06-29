function Client_GameRefresh(Game)
	if not refreshCalled then
        refreshCalled = true;
        game = Game;
        UI.InterceptNextBonusLinkClick(handleBonusLinkClick);
    end
end

function handleBonusLinkClick(bonusDetails)
    if bonusDetails ~= nil then
        local t = {};
        for _, id in pairs(Mod.PublicGameData.Bonuses[bonusDetails.ID]) do
            table.insert(t, id);
        end
        game.HighlightTerritories(t);
    end
    UI.InterceptNextBonusLinkClick(handleBonusLinkClick);
end