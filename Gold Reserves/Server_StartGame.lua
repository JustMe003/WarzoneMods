require("Annotations");

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    local res = standing.Resources;
    if res == nil then res = {}; end
    for _, player in pairs(game.Game.PlayingPlayers) do
        if player.Slot ~= nil and Mod.Settings.Config[player.Slot] ~= nil then
            if res[player.ID] == nil then res[player.ID] = {}; end
            local t = {};
            for i, v in pairs(res[player.ID]) do
                t[i] = v;
            end
            t[WL.ResourceType.Gold] = math.max((t[WL.ResourceType.Gold] or 0) + Mod.Settings.Config[player.Slot], 0);
            res[player.ID] = t;
        end
    end
    for p, _ in pairs(game.Game.Players) do
        print(p .. " player has " .. res[p][WL.ResourceType.Gold] .. " gold");
    end
    standing.Resources = res;
end
