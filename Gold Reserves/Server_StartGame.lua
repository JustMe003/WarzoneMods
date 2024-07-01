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
    standing.Resources = res;
    for p, _ in pairs(game.Game.Players) do
        print(p .. " player has " .. standing.Resources[p][WL.ResourceType.Gold] .. " gold");
    end
end

-- 1 player has 25 gold
-- 775: 2 player has 31 gold
-- 775: 3 player has 1 gold
-- 775: 4 player has 52 gold
-- 775: 5 player has 4 gold
-- 775: 6 player has 13 gold
-- 775: 1311724 player has 34 gold
-- 775: 7 player has 14 gold
-- 775: 8 player has 1 gold
-- 775: 9 player has 14 gold
-- 775: 10 player has 24 gold
-- 775: 11 player has 3 gold
-- 775: 12 player has 3 gold
-- 775: 13 player has 16 gold
-- 775: 14 player has 1 gold
-- 775: 15 player has 1 gold
-- 775: 16 player has 78 gold
-- 775: 17 player has 2 gold
-- 775: 18 player has 3 gold
-- 775: 19 player has 4 gold
-- 775: 20 player has 3 gold
-- 775: 21 player has 4 gold
-- 775: 22 player has 11 gold
-- 775: 23 player has 2 gold
-- 775: 24 player has 5 gold
-- 775: 25 player has 7 gold
-- 775: 26 player has 2 gold
-- 775: 27 player has 8 gold
-- 775: 28 player has 2 gold
-- 775: 29 player has 4 gold
-- 775: 30 player has 3 gold
-- 775: 31 player has 2 gold
-- 775: 32 player has 2 gold
-- 775: 33 player has 3 gold
-- 775: 34 player has 2 gold
-- 775: 35 player has 3 gold
-- 775: 36 player has 4 gold
-- 775: 37 player has 6 gold
-- 775: 38 player has 3 gold
-- 775: 39 player has 4 gold