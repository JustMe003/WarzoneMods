require("Annotations");

---Server_StartGame
---@param game GameServerHook
---@param standing GameStanding
function Server_StartGame(game, standing)
    if not WL.IsVersionOrHigher or not WL.IsVersionOrHigher("5.26.1") then 
        return;
    end
    local res = standing.Resources;
    if res == nil then res = {}; end
    for _, player in pairs(game.Game.PlayingPlayers) do
        if res[player.ID] == nil then res[player.ID] = {}; end
        local t = {};
        for i, v in pairs(res[player.ID]) do
            t[i] = v;
        end
        if player.Slot ~= nil and Mod.Settings.Config[player.Slot] ~= nil then
            for i, v in pairs(res[player.ID]) do
                t[i] = v;
            end
            t[WL.ResourceType.Gold] = math.max((t[WL.ResourceType.Gold] or 0) + Mod.Settings.Config[player.Slot], 0);
        end
        res[player.ID] = t;
    end
    standing.Resources = res;
end