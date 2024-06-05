require("Annotations");

---Client_GameRefresh hook
---@param game GameClientHook
function Client_GameRefresh(game)
	if Mod.PublicGameData.HasUpdatedGold == nil and game.Game.TurnNumber == 1 then
        game.SendGameCustomMessage("Updating mod...", {}, function(t) end);
    end
end