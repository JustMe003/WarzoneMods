require("Annotations");
require("DataConverter")

---Server_AdvanceTurn_End hook
---@param game GameServerHook 
---@param addNewOrder fun(order: GameOrder) # Adds a game order, will be processed before any of the rest of the orders 
function Server_AdvanceTurn_End(game, addNewOrder)
    Game = game;
    local s = game.ServerGame.LatestTurnStanding;
	local t = optimize({
        Territories = serializeTerritories(s.Territories);
        Cards = serializeCards(s.Cards);
        Resources = s.Resources;
    });
    local serializedStanding = DataConverter.DataToString(t);
    -- print(serializedStanding);
    local data = Mod.PublicGameData;
    data.SerializedTurn = serializedStanding;
    Mod.PublicGameData = data;
end

function optimize(t)
    map = {};
    t = mapProperties(t);
    for i, v in ipairs(map) do
        print(i, v);
    end
    t.GameData = {
        MapID = Game.Map.ID,
        GameName = Game.Settings.Name,
        TurnNumber = Game.Game.TurnNumber,
        PlayerMap = mapPlayers(Game.Game.Players),
        PropertiesMap = map,
    }
    return t;
end

function mapPlayers(players) 
    local t = {};
    local slot = 0;
    for pID, player in pairs(players) do
        t[pID] = {
            Slot = slot,
            Name = player.DisplayName(nil, false)
        };
        slot = slot + 1;
    end
    return t;
end

function mapProperties(t)
    local ret = {};
    for key, value in pairs(t) do
        if type(key) == "string" then
            key = getKeyFromMap(key);
            end
        if type(value) == "table" then
            ret[key] = mapProperties(value);
        else
            ret[key] = value;
        end
    end
    return ret;
end

function getKeyFromMap(key)
    for numKey, stringKey in ipairs(map) do
        if stringKey == key then
            return numKey;
        end
    end
    table.insert(map, key);
    return #map;
end

function serializeGameData(game)
    return {
        MapID = game.Map.ID
    }
end

function serializeCards(c)
    local t = {};
    for i, cards in pairs(c) do
        t[i] = {
            Pieces = cards.Pieces,
            WholeCards = serializeWholeCards(cards.WholeCards)
        }
    end
    if not isEmptyTable(t) then
        return t;
    end
end

function serializeWholeCards(c)
    local t = {};
    for _, card in pairs(c) do
        t[card.CardID] = (t[card.CardID] or 0) + 1;
    end
    if not isEmptyTable(t) then
        return t;
    end
end

---Serialize territories
---@param t TerritoryStanding[]
function serializeTerritories(t)
    local r = {};
    for i, terr in pairs(t) do
        r[i] = {
            OwnerPlayerID = terr.OwnerPlayerID,
            Structures = terr.Structures,
            NumArmies = serializeArmies(terr.NumArmies);
        }
    end
    if not isEmptyTable(r) then
        return r;
    end
end

---Serialize armies
---@param t Armies
function serializeArmies(t)
    return {
        NumArmies = t.NumArmies,
        SpecialUnits = serializeSpecialUnits(t.SpecialUnits);
    }
end

---Serialize special units
---@param t SpecialUnit[]
function serializeSpecialUnits(t)
    local r = {};
    for _, sp in ipairs(t) do
        local serSP = copyProxyTable(sp);
        serSP.ID = nil;
        table.insert(r, serSP);
    end
    if not isEmptyTable(r) then    
        return r;
    end
end

function copyProxyTable(t)
    local c = {};
    for _, v in ipairs(t.readableKeys) do
        c[v] = t[v];
    end
    c.readableKeys = nil;
    c.writableKeys = nil;
    c.readonly = nil;
    return c;
end

function isEmptyTable(t)
    for _, _ in pairs(t) do
        return false;
    end
    return true;
end