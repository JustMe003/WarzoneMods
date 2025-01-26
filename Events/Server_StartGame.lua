function Server_StartGame(game, standing)
    local data = Mod.PublicGameData;
    data.SlotPlayerMap = createSlotPlayerMap(game.Game.PlayingPlayers);
    Mod.PublicGameData = data;
end

function createSlotPlayerMap(players)
    local t = {};
    for i, p in pairs(players) do
        if p.Slot ~= nil then
            t[p.Slot] = i;
        end
    end
    return t;
end