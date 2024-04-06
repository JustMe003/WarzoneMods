require("Annotations");

---@class Catan # Enums for the Catan structure
---@field Resources Resource # The resources that are aquirable
---@field ResourceToName table<Resource, string> # The names of the resources
---@field Structures EnumStructureType # The enums of the structure types
---@field Phases table<CatanPhase, integer> # The phases of the Catan orders
---@field Recipes EnumRecipe # The recipes enums
---@field OrderType EnumOrderType # The Catan order types
---@field Village EnumStructureType # The structure used for a village
---@field WarriorCamp EnumStructureType # The structure used for a Warrior camp

---@class EnumRecipe
---| 'Village' # Recipe enum for Village
---| 'UpgradeVillage' # Recipe enum for upgrading a village
---| 'Warrior' # Recipe enum for Warrior
---| 'WarriorCamp' # Recipe enum for Warrior camp

---@class CatanPhase
---| 'BuildVillage' # Phase enum for building villages
---| 'BuildWarriorCamp' # Phase enum for building warrior camps
---| 'UpgradeVillage' # Phase enum for upgrading villages

---@class EnumOrderType
---| 'BuildVillage' # Order type enum for building villages
---| 'UpgradeVillage' # Order type enum for upgrading villages
---| 'BuildWarriorCamp' # Order type enum for building warrior camps

---@alias Resource integer
---@alias Recipe Resource[]

Catan = {
    Resources = {1, 2, 3, 4, 5}, 
    ResourceToName = {
        "Wood", 
        "Stone", 
        "Metal", 
        "Wheat", 
        "Livestock"
    }, 
    StructuresToResource = {
        [4] = 1, 
        [15] = 2, 
        [3] = 3, 
        [10] = 4, 
        [13] = 5
    }, 
    Structures = {4, 15, 3, 10, 13, 1, 2},
    Phases = {
        BuildVillage = 0,
        BuildWarriorCamp = 5,
        UpgradeVillage = 10,
    },
    Recipes = {
        Village = 1,
        UpgradeVillage = 2,
        Warrior = 3,
        WarriorCamp = 4
    },
    OrderType = {
        "BuildVillage",
        "UpgradeVillage",
        "BuildWarriorCamp"
    },
    Village = 1,
    WarriorCamp = 2
};

---@class CatanOrder # The base class for a Catan order
---@field OrderType EnumOrderType # The order type
---@field PlayerID PlayerID # The ID of the player
---@field TerritoryID TerritoryID # The ID of the territory
---@field Phase CatanPhase # The phase in which the order will occur
---@field Cost Recipe # The cost of the order

---@class BuildVillageOrder: CatanOrder # Catan order for building a village

---@class UpgradeVillageOrder: CatanOrder # Catan order for upgrading a village
---@field Level integer # The level of the recipe

---@class BuildWarriorCampOrder: CatanOrder # Catan order for building a warrior camp

--[[
    City	1
    ArmyCamp	2
    Mine	3
    Smelter	4
    Crafter	5
    Market	6
    ArmyCache	7
    MoneyCache	8
    ResourceCache	9
    MercenaryCamp	10
    Power	11
    Draft	12
    Arena	13
    Hospital	14
    DigSite	15
    Attack	16
    Mortar	17
    Recipe	18
]]

---Initializes the recipes for the mod settings
---@return Recipe[] # The array of recipes that are in the game
function initRecipes()
    return {
        {1, 1, 0, 1, 1},        -- Village recipe
        {2, 2, 2, 2, 2},        -- Upgrade Village recipe
        {0, 0, 1, 1, 1},        -- Warrior recipe
        {1, 1, 1, 0, 0}         -- Warrior camp recipe
    };
end

---Creates and return a BuildVillageOrder
---@param playerID PlayerID # The ID of the player
---@param terrID TerritoryID # The ID of the territory
---@return BuildVillageOrder # The created BuildVillageOrder
function createBuildVillageOrder(playerID, terrID)
    return {
        OrderType = "BuildVillage",
        PlayerID = playerID,
        TerritoryID = terrID,
        Phase = Catan.Phases.BuildVillage,
        Cost = getRecipe(Catan.Recipes.Village)
    };
end

---Creates and returns a UpgradeVillageOrder
---@param playerID PlayerID # The ID of the player
---@param terrID TerritoryID # The ID of the territory
---@param level integer # The level of the recipe
---@return UpgradeVillageOrder # The created UpgradeVillageOrder
function createUpgradeVillageOrder(playerID, terrID, level)
    return {
        OrderType = "UpgradeVillage",
        PlayerID = playerID,
        TerritoryID = terrID,
        Phase = Catan.Phases.UpgradeVillage,
        Cost = getRecipeLevel(getRecipe(Catan.Recipes.UpgradeVillage), level),
        Level = level
    }
end

---Creates and returns a BuildWarriorCamp order
---@param playerID PlayerID # The ID of the player
---@param terrID TerritoryID # The ID of the territory
---@return BuildWarriorCampOrder # The created BuildWarriorCampOrder
function createBuildWarriorCampOrder(playerID, terrID)
    return {
        OrderType = "BuildWarriorCamp",
        PlayerID = playerID,
        TerritoryID = terrID,
        Phase = Catan.Phases.BuildWarriorCamp,
        Cost = getRecipe(Catan.Recipes.WarriorCamp)
    };
end

---Adds the passed order in the right place of the order list
---@param orderList CatanOrder[] # The order list
---@param newOrder CatanOrder # The order that need to be added to the order list
function addOrderToOrderList(orderList, newOrder)
    local index = 0;
    for i, order in ipairs(orderList) do
        if order.Phase > newOrder.Phase then
            index = i;
            break;
        end
    end
    if index == 0 then
        index = #orderList + 1;
    end

    table.insert(orderList, index, newOrder);
end

---Creates the list containing all the orders of every player
---@param players table<PlayerID, any> # A table with as index the IDs of all the players
---@param moveOrder table<integer, PlayerID> # The move order of the turn
---@param playerGameData table # The player game data
---@return CatanOrder[] # The list containing all the orders of every player
function createTurnOrderList(players, moveOrder, playerGameData)
    local indexes = {};
    for p, _ in pairs(players) do
        indexes[p] = 1;
    end
    
    local list = {};
    local phases = getPhasesInOrder();

    for _, phase in ipairs(phases) do
        local samePhase = true;
        while samePhase do
            samePhase = false;
            for _, p in pairs(moveOrder) do
                if playerGameData[p].OrderList ~= nil and indexes[p] ~= nil and indexes[p] <= #playerGameData[p].OrderList then
                    local order = playerGameData[p].OrderList[indexes[p]];
                    if order.Phase == phase then
                        samePhase = true;
                        table.insert(list, order);
                        indexes[p] = indexes[p] + 1;
                    end
                end
            end
        end
    end
    return list;
end

---Returns true if the resources table contains enough resources for the passed recipe 
---@param recipe Recipe # The recipe
---@param resources Resource[] # The resources
---@return boolean # True if the resources are enough to afford the recipe, false otherwise
function hasEnoughResources(recipe, resources)
    for _, res in ipairs(Catan.Resources) do
        if recipe[res] > resources[res] then
            return false;
        end
    end
    return true;
end

---Updates a player resource
---@param data table # Table to update
---@param p PlayerID # The ID of the player
---@param res Resource # The resource
---@param n integer # The amount
function updatePlayerResource(data, p, res, n)
    data[p].Resources[res] = data[p].Resources[res] + n;
end

---Add resources to a player
---@param data table # Table to update
---@param p PlayerID # The ID of the player
---@param resources Resource[] # The to be added resources
function addPlayerResources(data, p, resources)
    for res, n in ipairs(resources) do
        updatePlayerResource(data, p, res, n);
    end
end

---Remove resources to a player
---@param data table # Table to update
---@param p PlayerID # The ID of the player
---@param resources Resource[] # The to be removed resources
function removePlayerResources(data, p, resources)
    for res, n in ipairs(resources) do
        updatePlayerResource(data, p, res, -n);
    end
end

---Set the resources of a player
---@param data table # Table to update
---@param p PlayerID # The ID of the player
---@param resources Resource[] # The resources
function setPlayerResources(data, p, resources)
    for res, n in ipairs(resources) do
        data[p].Resources[res] = n;
    end
end

function getBuildVillageEnum()
    return "BuildVillage";
end

---Returns the right recipe
---@param id EnumRecipe # The recipe enum
---@return Recipe # The recipe
function getRecipe(id)
    return Mod.Settings.Config.Recipes[id];
end

---Returns the recipe name
---@param res Resource # The resource
---@return string # The name of the resource
function getResourceName(res)
    return Catan.ResourceToName[res];
end

---Returns the resource name from a structure
---@param terr TerritoryStanding
---@return string # The name of the resource, or "NONE" if the territory has an invalid state
function getResourceNameFromStructure(terr)
    if terr.Structures == nil or #terr.Structures ~= 1 then
        print("NO VALID AMOUNT OF STRUCTURES!!!");
        return "NONE";
    end
    -- There is only 1 structure on the territory
    for i, _ in pairs(terr.Structures) do
        return Catan.ResourceToName[Catan.StructuresToResource[i]];
    end
end

---Get the resource on a territory
---@param terr TerritoryStanding # The territory from which you want to know the resource 
---@return Resource | nil # The integer representing the resource or nil when the territory has an invalid territory state
function getResource(terr)
    if terr.Structures == nil or #terr.Structures ~= 1 then
        print("NO VALID AMOUNT OF STRUCTURES!!!");
        return;
    end
    -- There is only 1 structure on the territory
    for i, _ in pairs(terr.Structures) do
        return Catan.StructuresToResource[i];
    end
end

---Returns the catan turn phases in order
---@return CatanPhase[] | nil # The catan turn phases
function getPhasesInOrder()
    local t = {};
    for _, n in pairs(Catan.Phases) do
        table.insert(t, n);
    end
    return table.sort(t);

end

---Returns true if the table contains all of the provided fields
---@param t table # The table
---@param fields any[] # Array containing all the fields that should be in the provided table
---@return boolean # True if the table contains all the fields. If a field is not present in the table, it will also return the field
---@return any # If a field is not present, the field will also be returned
function tableHasFields(t, fields)
    for _, field in ipairs(fields) do
        if t[field] == nil then return false, field; end
    end
    return true, nil;
end

---Returns true if the structures data contains a village, false otherwise
---@param structures table<EnumStructureType, integer> # The structures data
---@return boolean # True if the data contains a village, false if not
function terrHasVillage(structures)
    return structures ~= nil and structures[Catan.Village] ~= nil and structures[Catan.Village] > 0;
end

function getNumberOfVillages(structures)
    if structures == nil or structures[Catan.Village] == nil then return 0; end
    return structures[Catan.Village];
end

---Returns true if the structures data contains a warrior camp, false otherwise
---@param structures table<EnumStructureType, integer> # The structures data
---@return boolean # True if the data contains a warrior camp, false if not
function terrHasWarriorCamp(structures)
    return structures ~= nil and structures[Catan.WarriorCamp] ~= nil and structures[Catan.WarriorCamp] > 0;
end

---Returns true if the structures data should contain a resource, that is, it has no village or warrior camp. False otherwise
---@param structures table<EnumStructureType, integer> # The structures data
---@return boolean # True if the territory should have a structure, false if not
function terrHasResource(structures)
    return not (terrHasVillage(structures) or terrHasWarriorCamp(structures));
end

---Simulates throwing 2 fair 6-sided die
---@return integer # the summed up simulated die result
function throwDice()
    return math.random(1, 6) + math.random(1, 6);
end

---Returns the die group array from the number
---@param publicGameData table
---@param num integer
---@return table[]
function getDieGroup(publicGameData, num)
    -- DieGroups is an array with keys 1 - 11, but num will be from 2 - 12
    -- Hence we subtract 1 from the number thrown
    return publicGameData.DieGroups[num - 1];
end

---Sets up the map and player data for the game
---@param game GameServerHook
---@param standing GameStanding
function setupData(game, standing)
    local data = Mod.PublicGameData;
    local dieNumbers = {};
    local orderedByNumber = {};
    for i = 1, 11 do
        orderedByNumber[i] = {};
    end

    for terrID, _ in pairs(standing.Territories) do
        local terrStructures = standing.Territories[terrID].Structures;
        terrStructures = {};
        local rand = Catan.Structures[math.random(1, 5)];
        terrStructures[rand] = 1;
        standing.Territories[terrID].Structures = terrStructures;
        local dieNumber = math.random(2, 12);
        table.insert(dieNumbers, {TerrID = terrID, DiceValue = dieNumber});
        table.insert(orderedByNumber[dieNumber - 1], terrID);
    end

    data.DieNumbers = table.sort(dieNumbers, function(a, b) if a.TerrID <= b.TerrID then return false; else return true; end end);
    data.DieGroups = orderedByNumber;
    Mod.PublicGameData = data;

    local playerData = Mod.PlayerGameData;
    setResourcesTable(game.Game.PlayingPlayers, playerData);
    Mod.PlayerGameData = playerData;
end

---Initiates the resources table in the data struct
---@param players table<PlayerID, any>
---@param data table
function setResourcesTable(players, data)
    for playerID, _ in pairs(players) do
        data[playerID] = {};
        local t = {};
        for _, resource in ipairs(Catan.Resources) do
            t[resource] = 4;
        end
        data[playerID].Resources = t;
    end
end

---Makes the territory ready to allow a village by removing it's resource
---@param publicGameData table
---@param terrID integer
function setToVillage(publicGameData, terrID)
    removeResource(publicGameData, terrID);
end

---Makes the territory ready to allow a warrior camp by removing it's resource
---@param publicGameData table
---@param terrID integer
function setToWarriorCamp(publicGameData, terrID)
    removeResource(publicGameData, terrID);
end

---Removes a resource (fully) from the map and data
---@param publicGameData table
---@param terrID integer
---@return table
function removeResource(publicGameData, terrID)
    local diceValue = getTerritoryDiceValue(publicGameData, terrID);
    local dieGroup = getDieGroup(publicGameData, diceValue);
    local index = 0;
    for i, id in ipairs(dieGroup) do
        if id == terrID then
            index = i;
            break;
        end
    end
    if index ~= 0 then
        table.remove(dieGroup, index);
    end
    table.remove(publicGameData.DieNumbers, getTerritoryIndex(publicGameData, terrID));
    return publicGameData;
end

---Initiates the custom order lists
---@param players table # The table containing all the players
---@param playerGameData table # The data struct containing the player game data
function setOrderLists(players, playerGameData)
    for i, _ in pairs(players) do
        playerGameData[i].OrderList = {};
    end
end

---Returns the dice value of the territory, performs binary search
---@param data table # The data in which the array is stored
---@param terrID integer # the territory ID that identifies the data location
---@return integer # The dice value of the territory
function getTerritoryDiceValue(data, terrID)
    return getTerritoryData(data, terrID, 1, #data.DieNumbers).DiceValue;
end

---Returns the index of which the territory data is located, performs binary search
---@param data table # The data in which the array is stored
---@param terrID integer # the territory ID that identifies the data location
---@return integer # The index on which the data is stored
function getTerritoryIndex(data, terrID)
    return getTerritoryData(data, terrID, 1, #data.DieNumbers).Index;
end

---Performs binary search on the data to find the data that is identified by terrID
---@param data table # The data in which the array is stored
---@param terrID integer # The territory ID that identifies the data location
---@param l integer # The left bound
---@param r integer # The right bound
---@return table # The found data
function getTerritoryData(data, terrID, l, r)
    if l == r then
        return mergeTables(data.DieNumbers[l], {Index = l});
    end
    local m = math.floor((r - l) / 2) + l;
    if data.DieNumbers[m].TerrID < terrID then 
        return getTerritoryData(data, terrID, l, m - 1);
    elseif data.DieNumbers[m].TerrID > terrID then
        return getTerritoryData(data, terrID, m + 1, r);
    else
        return mergeTables(data.DieNumbers[m], {Index = m});
    end
end

---Merge the 2 given tables into 1. Identical keys will be overridden by the smaller table
---@param t1 table # The first table to be merged
---@param t2 table # The second table to be merged
---@return table # The merged tables
function mergeTables(t1, t2)
    if t1 == nil and t2 == nil then return {}; end
    if t1 == nil then return t2; end
    if t2 == nil then return t1; end
    if #t1 > #t2 then
        for i, v in pairs(t2) do
            t1[i] = v;
        end
        return t1;
    else
        for i, v in pairs(t1) do
            t2[i] = v;
        end
        return t2;
    end
end

---Multiplies the recipe times mult
---@param recipe Recipe # The recipe to be multiplied
---@param mult integer # The multiplier
---@return Recipe # The multiplied recipe
function multiplyRecipe(recipe, mult)
    local t = {};
    for i, res in ipairs(recipe) do
        t[i] = res * mult;
    end
    return t;
end

---Multiplies the recipe till it reaches the level
---@param recipe Recipe # The recipe that will be multiplied
---@param level integer # The level by which is should be multiplied
---@return Recipe # The multiplied recipe
function getRecipeLevel(recipe, level)
    local t = multiplyRecipe(recipe, 1);      -- copy the recipe;
    while level > 1 do
        t = multiplyRecipe(t, 2);
        level = level - 1;
    end
    return t;
end

---Creates and returns a deep copy of the original table
---@param orig table # The table to be copied
---@return table # A deep copy of the original table
function copyTable(orig)
    local t = {};
    for i, v in pairs(orig) do
        if type(v) == type({}) then
            t[i] = copyTable(v);
        else
            t[i] = v;
        end
    end
    return t;
end

---Returns the expected gain in 36 turns from the given number.
---d2 = d12 = 1, d3 = d11 = 2, ..., d7 = 6
---@param num number # The dice value of the territory
---@return number # The number of times num is expected to be thrown in 36 turns
function getExpectedGainsIn36Turns(num)
    return 6 - math.abs(num - 7);
end

---Compares and returns whether the tables have the exact same contents
---@param t1 table # The first table
---@param t2 table # The second table
---@return boolean # True if the tables have the same contents, false otherwise
function compareTables(t1, t2)
    if t1 == nil or t2 == nil then return false; end
    for i, v in pairs(t1) do
        if type(v) == type({}) then
            if not compareTables(v, t2[i]) then
                return false;
            end
        elseif type(v) ~= type(t2[i]) or v ~= t2[i] then
            return false;
        end
    end
    return true;
end

---Returns true if the value is present in the table, false otherwise
---@param t table # The table that might contain the value
---@param v any # The value that might be present in the table
---@return boolean # True if the value is in the table, false otherwise
function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end