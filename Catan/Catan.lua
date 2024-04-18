require("Annotations");

---@class Catan # Enums for the Catan structure
---@field Resources Resource[] # The resources that are aquirable
---@field ResourceToName table<Resource, ResourceName> # The names of the resources
---@field ResourceColor table<Resource, ResourceColor> # The color codes of the resources
---@field StructuresToResource table<CatanStructureType, Resource> # The structures mapped to their resources
---@field ResourceStructures CatanStructureType[] # The enums of the structure types
---@field Phases table<EnumCatanPhase, CatanPhase> # The phases of the Catan orders
---@field Recipes table<EnumRecipe, RecipeID> # The recipes enums
---@field OrderType table<EnumOrderType, CatanOrderType> # The Catan order types
---@field UnitType table<EnumUnitType, CatanUnitType> # The Catan unit types
---@field TechTrees table<EnumTechTree, CatanTechTree> # The Catan tech trees
---@field Research table<EnumResearch, CatanResearch> # The Catan researches
---@field Village CatanStructureType # The structure used for a village
---@field ArmyCamp CatanStructureType # The structure used for a Army camp

---@alias CatanStructureType EnumStructureType | integer
---@alias CatanTechTree integer

---@alias ResourceName
---| 'Wood' # Wood resource
---| 'Stone' # Stone resource
---| 'Metal' # Metal resource
---| 'Wheat' # Wheat resource
---| 'Livestock' # Livestock resource

---@alias ResourceColor string

---@alias EnumRecipe
---| 'Village' # Recipe enum for Village
---| 'UpgradeVillage' # Recipe enum for upgrading a village
---| 'Army' # Recipe enum for Army
---| 'ArmyCamp' # Recipe enum for Army camp

---@alias RecipeID integer

---@alias EnumCatanPhase
---| 'ExchangeResources' # Phase enum for exchanging resources
---| 'BuildVillage' # Phase enum for building villages
---| 'BuildArmyCamp' # Phase enum for building army camps
---| 'UpgradeVillage' # Phase enum for upgrading villages
---| 'PurchaseUnits' # Phase enum for purchasing units
---| 'TurnEnd' # Phase enum for orders that happen at the end of the turn

---@alias CatanPhase integer

---@alias EnumOrderType
---| 'ExchangeResourceWithBank' # Order type enum for exchanging resources with the bank
---| 'BuildVillage' # Order type enum for building villages
---| 'UpgradeVillage' # Order type enum for upgrading villages
---| 'BuildArmyCamp' # Order type enum for building army camps
---| 'PurchaseUnits' # Order type enum for purchasing units
---| 'SplitUnitStack' # Order type enum for splitting unit stacks

---@alias CatanOrderType integer

---@alias EnumUnitType
---| 'Infantry' # Unit enum for infantry units
---| 'Artillery' # Unit enum for artillery units
---| 'Tank' # Unit enum for tank units
---| 'Plane' # Unit enum for plane units
---| 'Bandit' # Unit enum for bandit units

---@alias CatanUnitType integer

---@alias UnitBuildFunction fun(modifiers: table, playerID: PlayerID, count: integer): CustomSpecialUnit

---@alias Resource
---| 1 # Wood
---| 2 # Stone
---| 3 # Metal
---| 4 # Wheat
---| 5 # Livestock

---@class Recipe
---@field [1] integer # Wood
---@field [2] integer # Stone
---@field [3] integer # Metal
---@field [4] integer # Wheat
---@field [5] integer # Livestock

---@type Catan
Catan = {
    Resources = {1, 2, 3, 4, 5}, 
    ResourceToName = {
        "Wood", 
        "Stone", 
        "Metal", 
        "Wheat", 
        "Livestock"
    },
    ResourceColor = {
        "#B03C3C",
        "#AD7E7E",
        "#BABABC",
        "#FFFF00",
        "#FFE5B4"
    },
    StructuresToResource = {
        [4] = 1, 
        [15] = 2, 
        [3] = 3, 
        [10] = 4, 
        [13] = 5
    }, 
    ResourceStructures = {4, 15, 3, 10, 13},
    Phases = {
        ExchangeResources = 0,
        BuildVillage = 5,
        BuildArmyCamp = 10,
        UpgradeVillage = 15,
        PurchaseUnits = 20,
        TurnEnd = 1000
    },
    Recipes = {
        Village = 1,
        UpgradeVillage = 2,
        ArmyCamp = 3,
    },
    OrderType = {
        ExchangeResourceWithBank = 1,
        BuildVillage = 2,
        UpgradeVillage = 3,
        BuildArmyCamp = 4,
        PurchaseUnits = 5,
        SplitUnitStack = 6,
    },
    UnitType = {
        Infantry = 1,
        Artillery = 2,
        Tank = 3,
        Plane = 4,
        Bandit = 5
    },
    TechTrees = {
        UnitTechTree = 1
    },
    Research = {
        BoostUnitHealth = 1,
        BoostUnitAttackPower = 2,
        BoostUnitDefensePower = 3,
        IncreaseUnitPurchaseLimit = 4,
        UnlockUnit = 5,
    },
    Village = 1,
    ArmyCamp = 2
};

_DefaultCatanTechs = {
    UnlockInfantryUnit = 1,
    BoostInfantryHealth = 2,
    BoostInfantryAttackPower = 3,
    BoostInfantryDefensePower = 4,
    IncreaseInfantryPurchaseLimit = 5,
    UnlockArtilleryUnit = 6,
    BoostArtilleryHealth = 7,
    BoostArtilleryAttackPower = 8,
    BoostArtilleryDefensePower = 9,
    IncreaseArtilleryPurchaseLimit = 10,
    UnlockTankUnit = 11,
    BoostTankHealth = 12,
    BoostTankAttackPower = 13,
    BoostTankDefensePower = 14,
    IncreaseTankPurchaseLimit = 15,
    UnlockPlaneUnit = 16,
    BoostPlaneHealth = 17,
    BoostPlaneAttackPower = 18,
    BoostPlaneDefensePower = 19,
    IncreasePlanePurchaseLimit = 20
}

---@class CatanOrder # The base class for a Catan order
---@field OrderType CatanOrderType # The order type
---@field PlayerID PlayerID # The ID of the player
---@field TerritoryID TerritoryID? # The ID of the territory
---@field Phase CatanPhase # The phase in which the order will occur
---@field Cost Recipe # The cost of the order

---@class ExchangeResourceWithBankOrder : CatanOrder # Catan order for exchanging resources with the bank
---@field Gain table<Resource, integer> # The resources the player gets
---@field ExchangeRate integer # The exchange rate at the time of the order

---@class BuildVillageOrder: CatanOrder # Catan order for building a village

---@class UpgradeVillageOrder: CatanOrder # Catan order for upgrading a village
---@field Level integer # The level of the recipe

---@class BuildArmyCampOrder: CatanOrder # Catan order for building a army camp

---@class PurchaseUnitsOrder: CatanOrder # Catan order for purchasing units
---@field Units table<CatanUnitType, integer> # Table containing the number of each unit that will be bought

---@class SplitUnitStack: CatanOrder # Catan order for splitting an army stack
---@field UnitType EnumUnitType # The type of the unit
---@field SplitPercentage number # The percentage of units that will split off


---@class TechTree # A single phase of a tech tree
---@field Name string # The name of the phase
---@field Node TechTreeNode # The tech tree nodes in this phase

---@class PlayerTechTree: TechTree # A single phase of a tech tree for a player
---@field NumResearched integer # The number of researche nodes that the player has researched so far
---@field TotalResearchNodes integer # The number of research nodes the phase contains
---@field Node PlayerTechTreeNode[] # The nodes in this node


---@class TechTreeNode # A tech tree node
---@field Mode EnumTechTreeNodeMode # The mode of the researches
---@field IsLoop boolean # True if the node is a loop, false otherwise
---@field LoopLimit integer? # The maximum amount this loop can be researched
---@field FreeCostMultiplier number? # The multiplier of the free cost of the researches
---@field FixedCostMultiplier number? # The fixed cost multiplier of the researches
---@field IsResearch false # True if the Nodes field contains research nodes, false otherwise
---@field Nodes TechTreeChildNode[] # The nodes in this node

---@alias TechTreeChildNode TechTreeNode | ResearchNode
---@alias PlayerTechTreeChildNode PlayerTechTreeNode | PlayerResearchNode

---@class PlayerTechTreeNode: TechTreeNode # A tech tree node for a player
---@field Unlocked boolean # True if the node has been unlocked yet
---@field LoopCounter integer? # Counts the number of times this loop has been completed
---@field Nodes PlayerTechTreeChildNode # The nodes in this node

---@class ResearchNode # A research
---@field Type CatanResearch # The research type
---@field IsResearch true 
---@field FixedCost Recipe # The fixed cost of the research
---@field FreeCost integer # The free cost of the research

---@class PlayerResearchNode: ResearchNode # A research of a player
---@field Researched boolean # True if the player has researched this research
---@field ResearchOccurance integer # The number of the same research are before this + 1
---@field Unlocked boolean # True if the player has unlocked this research

---@alias CatanResearch integer

---@alias EnumTechTree
---| 'UnitTechTree'

---@alias EnumResearch
---| 'BoostUnitHealth'
---| 'BoostUnitAttackPower'
---| 'BoostUnitDefensePower'
---| 'IncreaseUnitPurchaseLimit'
---| 'UnlockUnit'
---| 'IncreaseResourceDoubleModifier'
---| 'DecreaseBankExchangeRate'


---@alias EnumTechTreeNodeMode
---| 'Parallel' # Enum for a tech tree node. The research nodes must be researched parallel
---| 'Serial' # Enum for a tech tree node. The research nodes must be researched in serial



---Initializes the recipes for the mod settings
---@return Recipe[] # The array of recipes that are in the game
function initRecipes()
    return {
        {1, 1, 0, 1, 1},        -- Village recipe
        {2, 2, 2, 2, 2},        -- Upgrade Village recipe
        {2, 2, 1, 0, 0},        -- Army camp recipe
    };
end

---Initializes and return the modifiers table
---@return table # The modifiers table
function initModifiers()
    local t = {
        Resources = {
            ExchangeRateBank = {};
        },
        Units = {
            [Catan.UnitType.Infantry] = {
                Unlocked = true,
                Recipe = {0, 0, 1, 1, 1},
                BaseModifier = 1,
                MaxPurchasePerCamp = 1,
                Health = 1,
                AttackPower = 1,
                DefensePower = 1
            },
            [Catan.UnitType.Artillery] = {
                Unlocked = false,
                Recipe = {1, 1, 2, 0, 1},
                BaseModifier = 3,
                MaxPurchasePerCamp = 1,
                Health = 3,
                AttackPower = 3,
                DefensePower = 3
            },
            [Catan.UnitType.Tank] = {
                Unlocked = false,
                Recipe = {1, 2, 4, 2, 2},
                BaseModifier = 6,
                MaxPurchasePerCamp = 1,
                Health = 6,
                AttackPower = 6,
                DefensePower = 6
            },
            [Catan.UnitType.Plane] = {
                Unlocked = false,
                Recipe = {2, 1, 8, 2, 2},
                BaseModifier = 10,
                MaxPurchasePerCamp = 1,
                Health = 10,
                AttackPower = 10,
                DefensePower = 10
            },
            [Catan.UnitType.Bandit] = {
                BaseModifier = 4,
                Health = 4,
                AttackPower = 4,
                DefensePower = 4
            }
        }
    };

    for res, _ in ipairs(Catan.Resources) do
        t.Resources.ExchangeRateBank[res] = 4;
    end

    return t;
end

function initDefaultTechs()
    local techs = {
        [_DefaultCatanTechs.UnlockInfantryUnit] = {
            Command = Catan.Research.UnlockUnit,
            Name = "Infantry research",
            Description = "Unlocks the infantry unit",
            Parameters = {
                Type = Catan.UnitType.Infantry
            }
        },
        [_DefaultCatanTechs.BoostInfantryHealth] = {
            Command = Catan.Research.BoostUnitHealth,
            Name = "Better Infantry Training",
            Description = "Increase the health of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Infantry,
                Boost = 0.1
            }
        },
        [_DefaultCatanTechs.BoostInfantryAttackPower] = {
            Command = Catan.Research.BoostUnitAttackPower,
            Name = "Infantry Gun Upgrade",
            Description = "Increase the attack power of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Infantry,
                Boost = 0.1,
            }
        },
        [_DefaultCatanTechs.BoostInfantryDefensePower] = {
            Command = Catan.Research.BoostUnitDefensePower,
            Name = "Infantry Better Armor",
            Description = "Increase the defense power of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Infantry,
                Boost = 0.1
            }
        },
        [_DefaultCatanTechs.IncreaseInfantryPurchaseLimit] = {
            Command = Catan.Research.IncreaseUnitPurchaseLimit,
            Name = "Infantry Barracks Extension",
            Description = "Increase the purchase limit of infantry units by 1",
            Parameters = {
                Type = Catan.UnitType.Infantry,
                Increment = 1
            }
        },
        [_DefaultCatanTechs.UnlockArtilleryUnit] = {
            Command = Catan.Research.UnlockUnit,
            Name = "Artillery research",
            Description = "Unlocks the artillery unit",
            Parameters = {
                Type = Catan.UnitType.Artillery
            }
        },
        [_DefaultCatanTechs.BoostArtilleryHealth] = {
            Command = Catan.Research.BoostUnitHealth,
            Name = "Better Positioning",
            Description = "Increase the health of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Artillery,
                Boost = 0.3
            }
        },
        [_DefaultCatanTechs.BoostArtilleryAttackPower] = {
            Command = Catan.Research.BoostUnitAttackPower,
            Name = "More Gun Precision",
            Description = "Increase the attack power of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Artillery,
                Boost = 0.3,
            }
        },
        [_DefaultCatanTechs.BoostArtilleryDefensePower] = {
            Command = Catan.Research.BoostUnitDefensePower,
            Name = "Artillery Armor Upgrade",
            Description = "Increase the defense power of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Artillery,
                Boost = 0.3
            }
        },
        [_DefaultCatanTechs.IncreaseArtilleryPurchaseLimit] = {
            Command = Catan.Research.IncreaseUnitPurchaseLimit,
            Name = "Artillery Factory Upgrade",
            Description = "Increase the purchase limit of infantry units by 1",
            Parameters = {
                Type = Catan.UnitType.Artillery,
                Increment = 1
            }
        },
        [_DefaultCatanTechs.UnlockTankUnit] = {
            Command = Catan.Research.UnlockUnit,
            Name = "Tanks research",
            Description = "Unlocks the tank unit",
            Parameters = {
                Type = Catan.UnitType.Artillery
            }
        },
        [_DefaultCatanTechs.BoostTankHealth] = {
            Command = Catan.Research.BoostUnitHealth,
            Name = "Camouflage Upgrade",
            Description = "Increase the health of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Tank,
                Boost = 0.6
            }
        },
        [_DefaultCatanTechs.BoostTankAttackPower] = {
            Command = Catan.Research.BoostUnitAttackPower,
            Name = "Increase Gun Caliber",
            Description = "Increase the attack power of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Tank,
                Boost = 0.6
            }
        },
        [_DefaultCatanTechs.BoostTankDefensePower] = {
            Command = Catan.Research.BoostUnitDefensePower,
            Name = "Thicken Armor Plates",
            Description = "Increase the defense power of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Tank,
                Boost = 0.6
            }
        },
        [_DefaultCatanTechs.IncreaseTankPurchaseLimit] = {
            Command = Catan.Research.IncreaseUnitPurchaseLimit,
            Name = "Tank Factory Upgrade",
            Description = "Increase the purchase limit of infantry units by 1",
            Parameters = {
                Type = Catan.UnitType.Tank,
                Increment = 1
            }
        },
        [_DefaultCatanTechs.UnlockPlaneUnit] = {
            Command = Catan.Research.UnlockUnit,
            Name = "Planes research",
            Description = "Unlocks the plane unit",
            Parameters = {
                Type = Catan.UnitType.Artillery
            }
        },
        [_DefaultCatanTechs.BoostPlaneHealth] = {
            Command = Catan.Research.BoostUnitHealth,
            Name = "More Silent Planes",
            Description = "Increase the health of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Plane,
                Boost = 1
            }
        },
        [_DefaultCatanTechs.BoostPlaneAttackPower] = {
            Command = Catan.Research.BoostUnitAttackPower,
            Name = "Improve Bombing Precision",
            Description = "Increase the attack power of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Plane,
                Boost = 1
            }
        },
        [_DefaultCatanTechs.BoostPlaneDefensePower] = {
            Command = Catan.Research.BoostUnitDefensePower,
            Name = "Improve Weak Spots",
            Description = "Increase the defense power of all infantry units by 10%",
            Parameters = {
                Type = Catan.UnitType.Plane,
                Boost = 1
            }
        },
        [_DefaultCatanTechs.IncreasePlanePurchaseLimit] = {
            Command = Catan.Research.IncreaseUnitPurchaseLimit,
            Name = "Improve Flight Training",
            Description = "Increase the purchase limit of infantry units by 1",
            Parameters = {
                Type = Catan.UnitType.Plane,
                Increment = 1
            }
        },

    };

    return techs;
end

function getTechName(settings, type)
    return settings.Techs[type].Name;
end

function getTechDescription(settings, type)
    return settings.Techs[type].Description;
end

function getTechParameters(settings, type)
    return settings.Techs[type].Parameters;
end

function getTechCommand(settings, type)
    return settings.Techs[type].Command;
end

function performTech(settings, data, playerID, type)
    local commandMap = {
        [Catan.Research.BoostUnitHealth] = techBoostUnitHealth,
        [Catan.Research.BoostUnitAttackPower] = techBoostUnitAttackPower,
        [Catan.Research.BoostUnitDefensePower] = techBoostUnitDefensePower,
        [Catan.Research.IncreaseUnitPurchaseLimit] = techIncreaseUnitPurchaseLimit,
        [Catan.Research.UnlockUnit] = techUnlockUnit
    }

    local techCommand = getTechCommand(settings, type);
    if valueInTable({Catan.Research.BoostUnitHealth, Catan.Research.BoostUnitAttackPower, Catan.Research.BoostUnitDefensePower}, techCommand) then
        data[playerID].UpdateUnits = data[playerID].UpdateUnits or {};
        local unitType = getTechParameters(settings, type).Type;
        data[playerID].UpdateUnits[unitType] = data[playerID].UpdateUnits[unitType] or getUnitHealthModifier(data[playerID].Modifiers, unitType);
    end

    commandMap[techCommand](data[playerID].Modifiers, getTechParameters(settings, type));
end

function techBoostUnitHealth(modifiers, params)
    local bool, field = tableHasFields(params, {"Type", "Boost"});
    if not bool then
        error(field .. " was not found in tech boost unit health");
    end
    modifiers.Units[params.Type].Health = modifiers.Units[params.Type].Health + params.Boost;
end

function techBoostUnitAttackPower(modifiers, params)
    local bool, field = tableHasFields(params, {"Type", "Boost"});
    if not bool then
        error(field .. " was not found in techunit  boost attack power");
    end
    modifiers.Units[params.Type].AttackPower = modifiers.Units[params.Type].AttackPower + params.Boost;
end

function techBoostUnitDefensePower(modifiers, params)
    local bool, field = tableHasFields(params, {"Type", "Boost"});
    if not bool then
        error(field .. " was not found in tech unit boost defense power");
    end
    modifiers.Units[params.Type].DefensePower = modifiers.Units[params.Type].DefensePower + params.Boost;
end

function techIncreaseUnitPurchaseLimit(modifiers, params)
    local bool, field = tableHasFields(params, {"Type", "Increment"});
    if not bool then
        error(field .. " was not found in tech unit increase purchase limit");
    end
    modifiers.Units[params.Type].MaxPurchasePerCamp = modifiers.Units[params.Type].MaxPurchasePerCamp + params.Increment;
end

function techUnlockUnit(modifiers, params)
    local bool, field = tableHasFields(params, {"Type"});
    if not bool then
        error(field .. " was not found in tech unlock unit");
    end
    modifiers.Units[params.Type].Unlocked = true;
end


function initDefaultunitTree()

    ---@type fun(mode: EnumTechTreeNodeMode, nodes: TechTreeChildNode[], isLoop: boolean, fixedCostMultiplier: number?, freeCostMultiplier: number?, loopLimit: integer?): TechTreeNode 
    local newNode = function(mode, nodes, isLoop, fixedCostMultiplier, freeCostMultiplier, loopLimit)
        return {
            Mode = mode,
            IsLoop = isLoop,
            Nodes = nodes,
            IsResearch = false,
            FixedCostMultiplier = fixedCostMultiplier,
            FreeCostMultiplier = freeCostMultiplier,
            loopLimit = loopLimit
        }
    end


    ---@type fun(nodes: TechTreeChildNode[], isLoop: boolean, fixedCostMultiplier: number?, freeCostMultiplier: number?, loopLimit: integer?): TechTreeNode 
    local par = function(nodes, isLoop, fixedCostMultiplier, freeCostMultiplier, loopLimit)
        return newNode("Parallel", nodes, isLoop, fixedCostMultiplier, freeCostMultiplier, loopLimit);
    end
    ---@type fun(nodes: TechTreeChildNode[], isLoop: boolean, fixedCostMultiplier: number?, freeCostMultiplier: number?, loopLimit: integer?): TechTreeNode 
    local ser = function(nodes, isLoop, fixedCostMultiplier, freeCostMultiplier, loopLimit)
        return newNode("Serial", nodes, isLoop, fixedCostMultiplier, freeCostMultiplier, loopLimit);
    end

    ---@type fun(type: CatanResearch, fixed: Recipe, free: integer): ResearchNode
    local newResearch = function(type, fixed, free)
        return {
            Type = type,
            IsResearch = true,
            FixedCost = fixed,
            FreeCost = free
        }
    end
    
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local inHP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostInfantryHealth, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local inAP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostInfantryAttackPower, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local inDP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostInfantryDefensePower, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local inPLI = function(fixed, free)
        return newResearch(_DefaultCatanTechs.IncreaseInfantryPurchaseLimit, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local arUL = function(fixed, free)
        return newResearch(_DefaultCatanTechs.UnlockArtilleryUnit, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local arHP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostArtilleryHealth, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local arAP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostArtilleryAttackPower, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local arDP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostArtilleryDefensePower, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local arPLI = function(fixed, free)
        return newResearch(_DefaultCatanTechs.IncreaseArtilleryPurchaseLimit, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local taUL = function(fixed, free)
        return newResearch(_DefaultCatanTechs.UnlockTankUnit, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local taHP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostTankHealth, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local taAP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostTankAttackPower, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local taDP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostTankDefensePower, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local taPLI = function(fixed, free)
        return newResearch(_DefaultCatanTechs.IncreaseTankPurchaseLimit, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local plUL = function(fixed, free)
        return newResearch(_DefaultCatanTechs.UnlockPlaneUnit, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local plHP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostPlaneHealth, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local plAP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostPlaneAttackPower, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local plDP = function(fixed, free)
        return newResearch(_DefaultCatanTechs.BoostPlaneDefensePower, fixed, free);
    end
    ---@type fun(fixed: Recipe, free: integer): ResearchNode
    local plPLI = function(fixed, free)
        return newResearch(_DefaultCatanTechs.IncreasePlanePurchaseLimit, fixed, free);
    end

    ---@type TechTree
    local unitTechTree = 
    {
        Name = "Units Tech Tree",
        Node = par({
            ser({
                inPLI({1, 1, 1, 1, 1}, 0),
                par({
                    inHP({1, 1, 1, 1, 1}, 0),
                    inAP({1, 1, 1, 1, 1}, 0),
                    inDP({1, 1, 1, 1, 1}, 0),
                }, false),
                inPLI({1, 1, 1, 1, 1}, 5),
                par({
                    inHP({2, 2, 2, 2, 2}, 0),
                    inAP({2, 2, 2, 2, 2}, 0),
                    inDP({2, 2, 2, 2, 2}, 0),
                }, false),
                inPLI({2, 2, 2, 2, 2}, 5)
            }, false),
            ser({
                par({
                    inHP({1, 1, 1, 1, 1}, 0),
                    inAP({1, 1, 1, 1, 1}, 0),
                    inDP({1, 1, 1, 1, 1}, 0),
                }, false),
                par({
                    inHP({1, 1, 1, 1, 1}, 5),
                    inAP({1, 1, 1, 1, 1}, 5),
                    inDP({1, 1, 1, 1, 1}, 5),
                }, false),
                par({
                    inHP({2, 2, 2, 2, 2}, 0),
                    inAP({2, 2, 2, 2, 2}, 0),
                    inDP({2, 2, 2, 2, 2}, 0),
                }, false),
                inPLI({2, 2, 2, 2, 2}, 5),
                par({
                    ser({
                        arUL({0, 0, 0, 0, 0}, 30),
                        par({
                            arHP({2, 2, 2, 2, 2}, 0),
                            arAP({2, 2, 2, 2, 2}, 0),
                            arDP({2, 2, 2, 2, 2}, 0),
                        }, false),
                        par({
                            ser({
                                arHP({2, 2, 2, 2, 2}, 5),
                                arHP({2, 2, 2, 2, 2}, 5),
                                arPLI({0, 0, 0, 0, 0}, 20)
                            }, false),
                            ser({
                                arAP({2, 2, 2, 2, 2}, 5),
                                arAP({2, 2, 2, 2, 2}, 5),
                                arPLI({0, 0, 0, 0, 0}, 20)
                            }, false),
                            ser({
                                arDP({2, 2, 2, 2, 2}, 5),
                                arDP({2, 2, 2, 2, 2}, 5),
                                arPLI({0, 0, 0, 0, 0}, 20)
                            }, false)
                        }, false),
                        par({
                            arHP({3, 3, 3, 3, 3}, 0),
                            arAP({3, 3, 3, 3, 3}, 0),
                            arDP({3, 3, 3, 3, 3}, 0),
                        }, false),
                        par({
                            arHP({3, 3, 3, 3, 3}, 5),
                            arAP({3, 3, 3, 3, 3}, 5),
                            arDP({3, 3, 3, 3, 3}, 5),
                        }, false),
                        par({
                            ser({
                                arPLI({4, 4, 4, 4, 4}, 0),
                                taUL({0, 0, 0, 0, 0}, 50),
                                par({
                                    taHP({3, 3, 3, 3, 3}, 10),
                                    taDP({3, 3, 3, 3, 3}, 10),
                                    taAP({3, 3, 3, 3, 3}, 10),
                                }, false),
                                par({
                                    ser({
                                        taPLI({5, 5, 5, 0, 0}, 10),
                                        par({
                                            taHP({3, 3, 3, 3, 3}, 15),
                                            taDP({3, 3, 3, 3, 3}, 15),
                                            taAP({3, 3, 3, 3, 3}, 15),
                                        }, false),
                                        taPLI({5, 5, 5, 0, 0}, 10),
                                        par({
                                            taHP({3, 3, 3, 3, 3}, 20),
                                            taDP({3, 3, 3, 3, 3}, 20),
                                            taAP({3, 3, 3, 3, 3}, 20),
                                        }, false),
                                        taPLI({5, 5, 5, 0, 0}, 10),
                                        par({
                                            ser({
                                                plUL({0, 0, 0, 0, 0}, 75),
                                                par({
                                                    plHP({3, 3, 3, 3, 3}, 10),
                                                    plDP({3, 3, 3, 3, 3}, 10),
                                                    plAP({3, 3, 3, 3, 3}, 10),
                                                }, false),
                                                plPLI({4, 4, 4, 4, 4}, 10),
                                                par({
                                                    plHP({3, 3, 3, 3, 3}, 15),
                                                    plDP({3, 3, 3, 3, 3}, 15),
                                                    plAP({3, 3, 3, 3, 3}, 15),
                                                }, false),
                                                par({
                                                    plHP({3, 3, 3, 3, 3}, 15),
                                                    plDP({3, 3, 3, 3, 3}, 15),
                                                    plAP({3, 3, 3, 3, 3}, 15),
                                                }, false),
                                                ser({
                                                    plPLI({2, 2, 2, 2, 2}, 20),
                                                    par({
                                                        plHP({3, 3, 3, 3, 3}, 15),
                                                        plDP({3, 3, 3, 3, 3}, 15),
                                                        plAP({3, 3, 3, 3, 3}, 15),
                                                    }, false),
                                                    par({
                                                        plHP({3, 3, 3, 3, 3}, 20),
                                                        plDP({3, 3, 3, 3, 3}, 20),
                                                        plAP({3, 3, 3, 3, 3}, 20),
                                                    }, false),
                                                }, true)
                                            }, false),
                                            ser({
                                                par({
                                                    taHP({3, 3, 3, 3, 3}, 20),
                                                    taDP({3, 3, 3, 3, 3}, 20),
                                                    taAP({3, 3, 3, 3, 3}, 20),
                                                }, false),
                                                par({
                                                    taHP({3, 3, 3, 3, 3}, 25),
                                                    taDP({3, 3, 3, 3, 3}, 25),
                                                    taAP({3, 3, 3, 3, 3}, 25),
                                                }, false),
                                                taPLI({4, 4, 4, 4, 4}, 20)
                                            }, true)
                                        }, false)
                                    }, false),
                                    ser({
                                        par({
                                            taHP({3, 3, 3, 3, 3}, 15),
                                            taDP({3, 3, 3, 3, 3}, 15),
                                            taAP({3, 3, 3, 3, 3}, 15),
                                        }, false),
                                        taPLI({5, 5, 5, 0, 0}, 10),
                                        par({
                                            taHP({3, 3, 3, 3, 3}, 15),
                                            taDP({3, 3, 3, 3, 3}, 15),
                                            taAP({3, 3, 3, 3, 3}, 15),
                                        }, false),
                                        par({
                                            taHP({3, 3, 3, 3, 3}, 15),
                                            taDP({3, 3, 3, 3, 3}, 15),
                                            taAP({3, 3, 3, 3, 3}, 15),
                                        }, false),
                                        taPLI({6, 6, 6, 0, 0}, 12),
                                    }, false)
                                }, false)
                            }, false),
                            ser({
                                arPLI({2, 2, 2, 2, 2}, 20),
                                par({
                                    arHP({3, 3, 3, 3, 3}, 5),
                                    arAP({3, 3, 3, 3, 3}, 5),
                                    arDP({3, 3, 3, 3, 3}, 5),
                                }, false),
                                par({
                                    arHP({4, 4, 4, 4, 4}, 5),
                                    arAP({4, 4, 4, 4, 4}, 5),
                                    arDP({4, 4, 4, 4, 4}, 5),
                                }, false)
                            }, true)
                        }, false)
                    }, false),
                    par({
                        ser({
                            inHP({2, 2, 2, 2, 2}, 4),
                            inHP({2, 2, 2, 2, 2}, 4),
                            inHP({2, 2, 2, 2, 2}, 4),
                            inPLI({3, 3, 3, 3, 3}, 5)
                        }, false),
                    }, true),
                    par({
                        ser({
                            inAP({2, 2, 2, 2, 2}, 4),
                            inAP({2, 2, 2, 2, 2}, 4),
                            inAP({2, 2, 2, 2, 2}, 4),
                            inPLI({3, 3, 3, 3, 3}, 5)
                        }, false),
                    }, true),
                    par({
                        ser({
                            inDP({2, 2, 2, 2, 2}, 4),
                            inDP({2, 2, 2, 2, 2}, 4),
                            inDP({2, 2, 2, 2, 2}, 4),
                            inPLI({3, 3, 3, 3, 3}, 5)
                        }, false)
                    }, true),
                }, false)
            }, false)
        }, false)
    };
    return unitTechTree;
end

function setPlayerResearchTrees(players, data, trees)
    for i, _ in pairs(players) do
        data[i].ResearchTrees = {};
        data[i].ResearchTrees[Catan.TechTrees.UnitTechTree] = convertToPlayerTree(initDefaultunitTree());
    end
end

---Converts a TechTree into a PlayerTechTree
---@param tree TechTree # The TechTree
---@return PlayerTechTree # The converted TechTree as a PlayerTechTree
function convertToPlayerTree(tree)
    local t = copyTable(tree);
    t.NumResearched = 0;
    t.TotalResearchNodes = countResearchNodes(t.Node);
    initPlayerTreeNode(t.Node, {});
    unlockNode(t.Node);
    return t;
end

function initPlayerTreeNode(node, occurances)
    for _, child in ipairs(node.Nodes) do
        if child.IsResearch then
            occurances[child.Type] = (occurances[child.Type] or 0) + 1;
            child.ResearchOccurance = occurances[child.Type];
        end
    end
    for _, child in ipairs(node.Nodes) do
        if not child.IsResearch then
            initPlayerTreeNode(child, occurances);
        end
    end
    resetAllChildNodes(node);
end

function resetAllChildNodes(node)
    node.Unlocked = false;
    if node.IsResearch then
        node.Researched = false;
    else
        for _, research in ipairs(node.Nodes) do
            resetAllChildNodes(research);
        end
    end
end

function countResearchNodes(node)
    if node.IsLoop then return 0; end
    local c = 0;
    for _, child in ipairs(node.Nodes) do
        if child.IsResearch then
            c = c + 1;
        else
            c = c + countResearchNodes(child);
        end
    end
    return c;
end

function researchNode(tree, node, isInLoop)
    if not node.IsResearch then
        error("This node is not a research node: " .. tree.Name .. " " .. tostring(node)); 
    end
    if not isInLoop then
        tree.NumResearched = tree.NumResearched + 1;
    end
    node.Researched = true
    checkTreeLocks(tree.Node);
end

function unlockNode(node)
    node.Unlocked = true;
    if node.IsResearch then
        return;
    end
    -- Node is not a research node
    if node.Mode == "Serial" then
        unlockNode(node.Nodes[1]);
    else
        -- Mode == "Parallel"
        for _, nodes in ipairs(node.Nodes) do
            unlockNode(nodes);
        end
    end
end

function checkTreeLocks(node)
    if node.IsResearch then
        -- print(getTechName(nil, node.Type));
        return node.Researched;
    end
    if node.Mode == "Serial" then
        for i, child in ipairs(node.Nodes) do
            if child.Unlocked and checkTreeLocks(child) then
                if i < #node.Nodes and not node.Nodes[i+1].Unlocked then
                    -- print(i, #node.Nodes, node.Nodes[i+1].Unlocked);
                    unlockNode(node.Nodes[i+1]);
                end
            else
                return false;
            end
        end
        if node.IsLoop then
            -- Node (serial) has been fully researched
            resetAllChildNodes(node);
            node.LoopCounter = (node.LoopCounter or 0) + 1;
            unlockNode(node);
            return false;
        end
        return true;
    else
        local hasResearchedChild = false;
        local isFullyResearched = true;
        for _, child in ipairs(node.Nodes) do
            if child.Unlocked and checkTreeLocks(child) then
                hasResearchedChild = true;
            else
                isFullyResearched = false;
            end
        end
        if isFullyResearched and node.IsLoop then
            resetAllChildNodes(node);
            node.LoopCounter = (node.LoopCounter or 0) + 1;
            unlockNode(node);
            return false;
        end
        return hasResearchedChild and not node.IsLoop;
    end
end

---Returns the unit build functions
---@return table<EnumUnitType, UnitBuildFunction> # The table with build functions
function getUnitBuildFunctions()
    return {
        [Catan.UnitType.Infantry] = createInfantryUnit,
        [Catan.UnitType.Artillery] = createArtilleryUnit,
        [Catan.UnitType.Tank] = createTankUnit,
        [Catan.UnitType.Plane] = createPlaneUnit
    }
end

---Creates and returns an exchange order with the bank
---@param modifiers table # Table containing the modifiers of the player
---@param playerID PlayerID # The ID of the player
---@param givenRes Resource # The resource that will be given away
---@param receivedRes Resource # The resource that will be obtained
---@param count integer # The amount of times the exchange is done
---@return ExchangeResourceWithBankOrder # The exchange order
function createResourceExchangeWithBankOrder(modifiers, playerID, givenRes, receivedRes, count)
    local cost = getEmptyResourceTable();
    local rate = getExchangeRateOfPlayer(modifiers)[givenRes];
    cost[givenRes] = rate * count;
    local gain = getEmptyResourceTable();
    gain[receivedRes] = count;
    ---@type ExchangeResourceWithBankOrder
    return {
        OrderType = getExchangeResourcesWithBankEnum(),
        PlayerID = playerID,
        Phase = Catan.Phases.ExchangeResources,
        Cost = cost,
        Gain = gain,
        ExchangeRate = rate
    }
end

---Creates and returns a BuildVillageOrder
---@param playerID PlayerID # The ID of the player
---@param terrID TerritoryID # The ID of the territory
---@return BuildVillageOrder # The created BuildVillageOrder
function createBuildVillageOrder(playerID, terrID)
    ---@type BuildVillageOrder
    return {
        OrderType = getBuildVillageEnum(),
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
    ---@type UpgradeVillageOrder
    return {
        OrderType = getUpgradeVillageEnum(),
        PlayerID = playerID,
        TerritoryID = terrID,
        Phase = Catan.Phases.UpgradeVillage,
        Cost = getRecipeLevel(getRecipe(Catan.Recipes.UpgradeVillage), level),
        Level = level
    }
end

---Creates and returns a BuildArmyCamp order
---@param playerID PlayerID # The ID of the player
---@param terrID TerritoryID # The ID of the territory
---@return BuildArmyCampOrder # The created BuildArmyCampOrder
function createBuildArmyCampOrder(playerID, terrID)
    ---@type BuildArmyCampOrder
    return {
        OrderType = getBuildArmyCampEnum(),
        PlayerID = playerID,
        TerritoryID = terrID,
        Phase = Catan.Phases.BuildArmyCamp,
        Cost = getRecipe(Catan.Recipes.ArmyCamp)
    };
end

function createPurchaseUnitsOrder(playerID, terrID, units, cost)
    ---@type PurchaseUnitsOrder
    return {
        OrderType = Catan.OrderType.PurchaseUnits,
        PlayerID = playerID,
        TerritoryID = terrID,
        Phase = Catan.Phases.PurchaseUnits,
        Cost = cost,
        Units = units,
    }
end

function createSplitUnitOrder(playerID, terrID, per, type)
    ---@type SplitUnitStack
    return {
        OrderType = getSplitUnitStackOrderEnum(),
        PlayerID = playerID,
        TerritoryID = terrID,
        Phase = Catan.Phases.TurnEnd,
        Cost = getEmptyResourceTable(),
        UnitType = type,
        SplitPercentage = per
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

function hasResearch(researchTree, research)
    return false;
end

---Returns true if the resources table contains enough resources for the passed recipe 
---@param recipe Recipe # The recipe
---@param resources table<Resource, integer> # The resources
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
---@param resources table<Resource, integer> # The to be added resources
function addPlayerResources(data, p, resources)
    for res, n in ipairs(resources) do
        updatePlayerResource(data, p, res, n);
    end
end

---Remove resources to a player
---@param data table # Table to update
---@param p PlayerID # The ID of the player
---@param resources table<Resource, integer> # The to be removed resources
function removePlayerResources(data, p, resources)
    for res, n in ipairs(resources) do
        updatePlayerResource(data, p, res, -n);
    end
end

---Set the resources of a player
---@param data table # Table to update
---@param p PlayerID # The ID of the player
---@param resources table<Resource, integer> # The resources
function setPlayerResources(data, p, resources)
    for res, n in ipairs(resources) do
        data[p].Resources[res] = n;
    end
end

---Creates and returns an empty resource table
---@return table<Resource, integer> # An empty resource table
function getEmptyResourceTable()
    local t = {};
    for _, res in ipairs(Catan.Resources) do
        t[res] = 0;
    end
    return t;
end

---Returns the ExchangeResourceWithBank enum
---@return CatanOrderType # The ExchangeResourceWithBank enum
function getExchangeResourcesWithBankEnum()
    return Catan.OrderType.ExchangeResourceWithBank;
end

---Returns the BuildVillage enum
---@return CatanOrderType # The BuildVillage enum
function getBuildVillageEnum()
    return Catan.OrderType.BuildVillage;
end

---Returns the UpgradeVillage enum
---@return CatanOrderType # The UpgradeVillage enum
function getUpgradeVillageEnum()
    return Catan.OrderType.UpgradeVillage;
end

---Returns the BuildArmyCamp enum
---@return CatanOrderType # The BuildArmyCamp enum
function getBuildArmyCampEnum()
    return Catan.OrderType.BuildArmyCamp;
end

---Returns the PurchaseUnit enum
---@return CatanOrderType # The PurchaseUnit enum
function getPurchaseUnitEnum()
    return Catan.OrderType.PurchaseUnits;
end

---Returns the SplitUnitStack enum
---@return CatanOrderType # The SplitUnitStack enum
function getSplitUnitStackOrderEnum()
    return Catan.OrderType.SplitUnitStack;
end

---Returns the right recipe
---@param id EnumRecipe # The recipe enum
---@return Recipe # The recipe
function getRecipe(id)
    return Mod.Settings.Config.Recipes[id];
end

function hasUnlockedUnit(modifiers, unit)
    return modifiers.Units[unit].Unlocked;
end

---Returns the unit recipe
---@param modifiers table # The modifiers table
---@param unit CatanUnitType # The unit type
---@return Recipe # The units recipe
function getUnitRecipe(modifiers, unit)
    return modifiers.Units[unit].Recipe;
end

---Get the unit purchase limit
---@param modifiers table # The modifiers table
---@param unit CatanUnitType # The unit type
---@return integer # The purchase limit per army camp for the unit
function getUnitPurchaseLimit(modifiers, unit)
    return modifiers.Units[unit].MaxPurchasePerCamp;
end

---Returns the recipe name
---@param res Resource # The resource
---@return ResourceName # The name of the resource
function getResourceName(res)
    return Catan.ResourceToName[res];
end

---Returns the color code in hexadecimal for the resources
---@param res Resource # The resource
---@return ResourceColor # The color code in hexadecimal
function getResourceColor(res)
    return Catan.ResourceColor[res];
end

---Returns the resource name from a structure
---@param terr TerritoryStanding
---@return ResourceName? # The name of the resource, or "NONE" if the territory has an invalid state
function getResourceNameFromStructure(terr)
    if terr.Structures == nil or #terr.Structures ~= 1 then
        print("NO VALID AMOUNT OF STRUCTURES!!!");
        return;
    end
    -- There is only 1 structure on the territory
    for i, _ in pairs(terr.Structures) do
        return Catan.ResourceToName[Catan.StructuresToResource[i]];
    end
end

---Get the resource on a territory
---@param terr TerritoryStanding # The territory from which you want to know the resource
---@return Resource? # The integer representing the resource or nil when the territory has an invalid territory state
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
    for p, n in pairs(Catan.Phases) do
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

---Returns the number of villages the structures table has
---@param structures table<EnumStructureType, integer> # The structures data
---@return integer # The number of villages there are in the structures data
function getNumberOfVillages(structures)
    if structures == nil or structures[Catan.Village] == nil then return 0; end
    return structures[Catan.Village];
end

---Returns true if the structures data contains a army camp, false otherwise
---@param structures table<EnumStructureType, integer> # The structures data
---@return boolean # True if the data contains a army camp, false if not
function terrHasArmyCamp(structures)
    return structures ~= nil and structures[Catan.ArmyCamp] ~= nil and structures[Catan.ArmyCamp] > 0;
end

---Returns true if the structures data should contain a resource, that is, it has no village or army camp. False otherwise
---@param structures table<EnumStructureType, integer> # The structures data
---@return boolean # True if the territory should have a structure, false if not
function terrHasResource(structures)
    return not (terrHasVillage(structures) or terrHasArmyCamp(structures));
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

    local structCount = #Catan.ResourceStructures;
    for terrID, _ in pairs(standing.Territories) do
        local terrStructures = standing.Territories[terrID].Structures;
        terrStructures = {};
        local rand = Catan.ResourceStructures[math.random(1, structCount)];
        terrStructures[rand] = 1;
        standing.Territories[terrID].Structures = terrStructures;
        local dieNumber = math.random(2, 12);
        table.insert(dieNumbers, {TerrID = terrID, DiceValue = dieNumber});
        table.insert(orderedByNumber[dieNumber - 1], terrID);
    end

    print(table.sort(dieNumbers, function(a, b) if a.TerrID <= b.TerrID then return false; else return true; end end));
    data.DieNumbers = table.sort(dieNumbers, sortOnTerrID);
    data.DieGroups = orderedByNumber;
    Mod.PublicGameData = data;

    print("test"); 
    for i, v in ipairs(Mod.PublicGameData) do
        print(i);
    end

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
        local recipe = multiplyRecipe(getRecipe(Catan.Recipes.Village), 2);
        for _, resource in ipairs(Catan.Resources) do
            t[resource] = recipe[resource];
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

---Makes the territory ready to allow a army camp by removing it's resource
---@param publicGameData table
---@param terrID integer
function setToArmyCamp(publicGameData, terrID)
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

---Sets up the data structure for all the modifiers
---@param players table<PlayerID, any> # The table containing all the players
---@param playerGameData table # The PlayerGameData storage
---@param config table # The config stored in the Mod.Settings storage
function setPlayerModifiers(players, playerGameData, config)
    for i, _ in pairs(players) do
        playerGameData[i].Modifiers = copyTable(config.Modifiers);
    end
end

---Returns the Infantry enum
---@return CatanUnitType # Returns the Infantry unit type
function getInfantryEnum()
    return Catan.UnitType.Infantry;
end

---Returns the Artillery enum
---@return CatanUnitType # Returns the Artillery unit type
function getArtilleryEnum()
    return Catan.UnitType.Artillery;
end

---Returns the Tank enum
---@return CatanUnitType # Returns the Tank unit type
function getTankEnum()
    return Catan.UnitType.Tank;
end

---Returns the Plane enum
---@return CatanUnitType # Returns the Plane unit type
function getPlaneEnum()
    return Catan.UnitType.Plane;
end

---Returns the type of the unit
---@param unit CustomSpecialUnit # The special unit
---@return CatanUnitType? # The unit type
function getUnitType(unit)
    local enum = unit.Name:gsub("%d* (%w*)", "%1");
    if enum:sub(-1, -1) == "s" then enum = enum:sub(1, -2); end
    if enum then
        return Catan.UnitType[enum];
    end
end

---Return the units that can be obtained from an army camp
---@return table<EnumUnitType, CatanUnitType> # The table containing the obtainable units from an army camp
function getArmyCampUnits()
    local c = copyTable(Catan.UnitType)
    c.Bandit = nil;
    return c;
end

function isCatanUnit(unit)
    local enum = unit.Name:gsub("%d* (%w*)", "%1");
    if enum:sub(-1, -1) == "s" then enum = enum:sub(1, -2); end
    return enum ~= nil and Catan.UnitType[enum] ~= nil;
end

---Returns the name of the unit by the unit type
---@param unitType CatanUnitType # The unit type
---@return EnumUnitType? # The unit type
function getUnitNameByType(unitType)
    for name, type in pairs(Catan.UnitType) do
        if type == unitType then return name; end
    end
end

---Returns the base modifier value of the unit
---@param modifiers table # table containing all the modifiers 
---@param type CatanUnitType # The type of the unit
---@return number # The base modifier of the unit
function getUnitBaseModifier(modifiers, type)
    return modifiers.Units[type].BaseModifier;
end

---Returns the health modifier of the unit
---@param modifiers table # table containing all the modifiers 
---@param type CatanUnitType # The type of the unit
---@return number # The health modifier of the unit
function getUnitHealthModifier(modifiers, type)
    return modifiers.Units[type].Health;
end

---Returns the attack power modifier of the unit
---@param modifiers table # table containing all the modifiers 
---@param type CatanUnitType # The type of the unit
---@return number # The attack power modifier of the unit
function getUnitAttackPowerModifier(modifiers, type)
    return modifiers.Units[type].AttackPower;
end

---Returns the defense power modifier of the unit
---@param modifiers table # table containing all the modifiers 
---@param type CatanUnitType # The type of the unit
---@return number # The defense power modifier of the unit
function getUnitDefensePowerModifier(modifiers, type)
    return modifiers.Units[type].DefensePower;
end

---Returns a new unit that has applied the damage correctly
---@param modifiers table # The modifiers table of the player owning the unit
---@param type CatanUnitType # The type of the unit
---@param unit CustomSpecialUnit # The unit
---@param n integer # The damage the unit will take
---@return CustomSpecialUnit # The new unit object
function getUnitAfterApplyingDamage(modifiers, type, unit, n)
    return getUnitBuildFunctions()[type](modifiers, unit.OwnerID, getNumberOfUnits(modifiers, unit) - (n / getUnitHealthModifier(modifiers, type)));
end

---Returns the number of units of the unit object
---@param unit CustomSpecialUnit # The special unit
---@return number # The number of units are in the object
function getNumberOfUnits(modifiers, unit)
    ---@diagnostic disable-next-line: return-type-mismatch
    return unit.Health / getUnitHealthModifier(modifiers, getUnitType(unit));
end

---Creates and returns an new Infantry unit
---@param modifiers table # The modifiers table of the player that will own the unit
---@param playerID PlayerID # The player ID of the owner
---@param count number # The number of infantry units
---@return CustomSpecialUnit # The Infantry unit
function createInfantryUnit(modifiers, playerID, count)
    count = count or 1
    local builder = WL.CustomSpecialUnitBuilder.Create(playerID);
    builder.Name = math.ceil(count) .. " Infantry";
    builder.TextOverHeadOpt = math.ceil(count);
    builder.IncludeABeforeName = false;
    builder.ImageFilename = "infantry.png";
    builder.AttackPower = round(getUnitAttackPowerModifier(modifiers, Catan.UnitType.Infantry) * count);
    builder.DefensePower = round(getUnitDefensePowerModifier(modifiers, Catan.UnitType.Infantry) * count);
    -- print(count, math.floor(getUnitHealthModifier(modifiers, Catan.UnitType.Infantry) * count));
    builder.Health = round(getUnitHealthModifier(modifiers, Catan.UnitType.Infantry) * count);
    builder.CombatOrder = 342;
    return builder.Build();
end

---Creates and returns an new Artillery unit
---@param modifiers table # The modifiers table of the player that will own the unit
---@param playerID PlayerID # The player ID of the owner
---@param count number # The number of Artillery units
---@return CustomSpecialUnit # The Artillery unit
function createArtilleryUnit(modifiers, playerID, count)
    count = count or 1
    local builder = WL.CustomSpecialUnitBuilder.Create(playerID);
    builder.Name = math.ceil(count) .. " Artillery";
    builder.TextOverHeadOpt = math.ceil(count);
    builder.IncludeABeforeName = false;
    builder.ImageFilename = "artillery.png";
    builder.AttackPower = round(modifiers.Units[Catan.UnitType.Artillery].AttackPower * count);
    builder.DefensePower = round(modifiers.Units[Catan.UnitType.Artillery].DefensePower * count);
    builder.Health = round(modifiers.Units[Catan.UnitType.Artillery].Health * count);
    builder.CombatOrder = 343;
    return builder.Build();
end

---Creates and returns an new Tank unit
---@param modifiers table # The modifiers table of the player that will own the unit
---@param playerID PlayerID # The player ID of the owner
---@param count number # The number of Tank units
---@return CustomSpecialUnit # The Tank unit
function createTankUnit(modifiers, playerID, count)
    count = count or 1
    local builder = WL.CustomSpecialUnitBuilder.Create(playerID);
    builder.Name = math.ceil(count) .. " Tanks";
    builder.TextOverHeadOpt = math.ceil(count);
    builder.IncludeABeforeName = false;
    builder.ImageFilename = "tank.png";
    builder.AttackPower = round(modifiers.Units[Catan.UnitType.Tank].AttackPower * count);
    builder.DefensePower = round(modifiers.Units[Catan.UnitType.Tank].DefensePower * count);
    builder.Health = round(modifiers.Units[Catan.UnitType.Tank].Health * count);
    builder.CombatOrder = 344;
    return builder.Build();
end

---Creates and returns an new Plane unit
---@param modifiers table # The modifiers table of the player that will own the unit
---@param playerID PlayerID # The player ID of the owner
---@param count number # The number of Plane units
---@return CustomSpecialUnit # The Plane unit
function createPlaneUnit(modifiers, playerID, count)
    count = count or 1
    local builder = WL.CustomSpecialUnitBuilder.Create(playerID);
    builder.Name = math.ceil(count) .. " Planes";
    builder.TextOverHeadOpt = math.ceil(count);
    builder.IncludeABeforeName = false;
    builder.ImageFilename = "plane.png";
    builder.AttackPower = round(modifiers.Units[Catan.UnitType.Plane].AttackPower * count);
    builder.DefensePower = round(modifiers.Units[Catan.UnitType.Plane].DefensePower * count);
    builder.Health = round(modifiers.Units[Catan.UnitType.Plane].Health * count);
    builder.CombatOrder = 345;
    return builder.Build();
end

---Creates a Catan CustomSpecialUnit
---@param modifiers table # The table with the players modifiers
---@param playerID PlayerID # The ID of the player
---@param type CatanUnitType # The type of the unit
---@param count integer # The number of units that has to be created
---@return CustomSpecialUnit # A Catan CustomSpecialUnit
function createUnit(modifiers, playerID, type, count)
    return getUnitBuildFunctions()[type](modifiers, playerID, count);
end

---Merges units together in 1 unit
---@param units CustomSpecialUnit[] # Array of at least 2 units of the same type and owner
---@param type CatanUnitType # The type of the unit
---@param modifiers table # The modifiers table of the player owning the units
---@return CustomSpecialUnit # The merged unit
function mergeUnits(units, type, modifiers)
    local unitCount = 0;
    for _, unit in ipairs(units) do
        unitCount = unitCount + getNumberOfUnits(modifiers, unit);
    end
    
    return getUnitBuildFunctions()[type](modifiers, units[1].OwnerID, unitCount);
end

function splitUnit(modifiers, unit, type, splitPercentage)
    local unitCount = getNumberOfUnits(modifiers, unit);
    local splitCount = round(unitCount * splitPercentage);
    local f = getUnitBuildFunctions()[type];
    return {
        f(modifiers, unit.OwnerID, unitCount - splitCount),
        f(modifiers, unit.OwnerID, splitCount)
    }
end

---Returns the dice value of the territory, performs binary search
---@param data table # The data in which the array is stored
---@param terrID integer # the territory ID that identifies the data location
---@return integer # The dice value of the territory
function getTerritoryDiceValue(data, terrID)
    for i, v in pairs(data) do
        print(i);
    end
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

---Returns the maximum number of the recipe that can be obtained with the given resources table
---@param recipe Recipe # The recipe
---@param resources Recipe # The resources
---@return integer # The number of times this recipe can be used
function getMaxRecipeUse(recipe, resources)
    local min;
    for res, n in ipairs(recipe) do
        if min then
            min = math.min(min, math.floor(resources[res] / n));
        else
            min = math.floor(resources[res] / n);
        end
    end
    return min;
end

---Combines and returns the 2 recipes
---@param r1 Recipe # Recipe 1
---@param r2 Recipe # Recipe 2
---@return Recipe # Combined Recipe
function combineRecipes(r1, r2)
    local t = {};
    for res, n in ipairs(r1) do
        t[res] = n + r2[res];
    end
    return t;
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
---@param mult integer? # The multiplier of each level
---@return Recipe # The multiplied recipe
function getRecipeLevel(recipe, level, mult)
    mult = mult or 2;
    local t = multiplyRecipe(recipe, 1);      -- copy the recipe;
    while level > 1 do
        t = multiplyRecipe(t, mult);
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

---Retrieves the order for the given territory ID, if available
---@param list CatanOrder[] # The orderlist
---@param type EnumOrderType # The order type
---@param terrID integer # The ID of the territory
---@return CatanOrder? # The order, or nil if there is no order
function retrieveOrder(list, type, terrID)
    for _, order in ipairs(list) do
        if order.OrderType == type and order.TerritoryID == terrID then
            return order;
        end
    end
end

---Returns a resources table with the expected gain score for the given territory
---@param standing TerritoryStanding # The territory standing object
---@param connections table<integer, EnumTerritoryConnectionWrap> # The connections of the territory
---@param data table # Table containing the dice values of a territory
---@param mult? integer # A multiplier
---@param exceptions TerritoryID[]? # A optional list of territory IDs that should not be part of the calculation
---@return Resource[] # The expected gain score of this territory
function getGainScoreFromOneTerr(standing, connections, data, mult, exceptions)
    mult = mult or 1;
    exceptions = exceptions or {};
    local t = {};
    for _, res in ipairs(Catan.Resources) do
        t[res] = 0;
    end
    for connID, _ in pairs(connections) do
        local conn = standing[connID];
        if terrHasResource(conn.Structures) and not valueInTable(exceptions, connID) and canSeeStructure(conn) then
            local res = getResource(conn);
            if res then
                t[res] = t[res] + (mult * getExpectedGainsIn36Turns(getTerritoryDiceValue(data, connID)));
            end
        end
    end
    return t;
end

---Returns a list of all territory IDs which have a build village order
---@param data table # Table containing the OrderList data
---@return TerritoryID[] # The list of territoryIDs
function extractBuildVillageTerrIDs(data)
    return extractTerrIDsFromOrders(data, getBuildVillageEnum());
end

---Returns a list of all territory IDs which have a upgrade village order
---@param data table # Table containing the OrderList data
---@return TerritoryID[] # The list of territoryIDs
function extractUpgradeVillageTerrIDs(data)
    return extractTerrIDsFromOrders(data, getUpgradeVillageEnum());
end

function extractBuildOrdersTerrIDs(data)
    return mergeTables(extractTerrIDsFromOrders(data, getBuildVillageEnum()), extractTerrIDsFromOrders(data, getUpgradeVillageEnum()));
end

---Returns a list of all territory IDs which have a build army camp order
---@param data table # Table containing the OrderList data
---@return TerritoryID[] # The list of territoryIDs
function extractBuildArmyCampTerrIDs(data)
    return extractTerrIDsFromOrders(data, getBuildArmyCampEnum());
end

---Returns a list of all territory IDs which have a purchase unit order
---@param data table # Table containing the OrderList data
---@return TerritoryID[] # The list of territoryIDs
function extractPurchaseUnitOrdersTerrIDs(data)
    return extractTerrIDsFromOrders(data, getPurchaseUnitEnum());
end

---Returns a list of all split unit orders 
---@param data table # Table containing the OrderList data
---@return SplitUnitStack[] # The list of territoryIDs
function extractSplitUnitOrders(data)
    return extractOrdersOfType(data, getSplitUnitStackOrderEnum());
end

---Returns a list of all orders of the passed type
---@param data table # Table containing the OrderList data
---@param type EnumOrderType | string # The order type
---@return CatanOrder[] # The list of orders
function extractOrdersOfType(data, type)
    if data == nil or data.OrderList == nil then return {}; end
    local t = {};
    for _, order in ipairs(data.OrderList) do
        if order.OrderType == type then
            table.insert(t, order);
        end
    end
    return t;
end

---Returns a list of all territory IDs that have an order of the passed type
---@param data table # Table containing the OrderList data
---@param type EnumOrderType | string # The order type
---@return TerritoryID[] # The list of territoryIDs
function extractTerrIDsFromOrders(data, type)
    if data == nil or data.OrderList == nil then return {}; end
    local t = {};
    for _, order in ipairs(data.OrderList) do
        if order.OrderType == type then
            table.insert(t, order.TerritoryID);
        end
    end
    return t;
end

function territoryIsFullyVisible(terr)
    return terr.FogLevel == WL.StandingFogLevel.You or terr.FogLevel == WL.StandingFogLevel.Visible;
end

function canSeeStructure(terr)
    return territoryIsFullyVisible(terr) or terr.FogLevel == WL.StandingFogLevel.OwnerOnly;
end

---Two arguments void function
---@param _ any # Voids the input
---@param _2 any # Voids the input
function TwoArgVoid(_, _2) end

---Void function
function void() end

---Prints 'TODO', work in progress
function TODO() print("TODO"); end

---Returns true if the passed table is empty, false otherwise
---@param t table # The input table
---@return boolean # True if the passed table is empty, false otherwise
function tableIsEmpty(t)
    for _, _ in pairs(t) do
        return false;
    end
    return true;
end

---Counts and returns the number of elements in the table
---@param t table # The table to be counted
---@return integer # The number of elements in the table
function getTableLength(t)
    print(tostring(t), t == nil);
    local c = 0;
    for _, _ in pairs(t) do
        c = c + 1;
    end
    return c;
end

---Returns the exchange rate of all resources of a player
---@param modifiers table # The modifiers table of the player
---@return table<Resource, integer> # The resource exchange rate of each resource
function getExchangeRateOfPlayer(modifiers)
    return modifiers.Resources.ExchangeRateBank;
end

function countTotalResources(resources)
    local c = 0;
    for _, n in ipairs(resources) do
        c = c + n;
    end
    return c;
end

function round(n, dec)
    local mult = 10^(dec or 0)
    return math.floor(n * mult + 0.5) / mult
end

function makeSet(array)
    local t = {};
    for _, v in pairs(array) do
        if not valueInTable(t, v) then
            table.insert(t, v);
        end
    end
    return t;
end

function getRomanNumber(n)
    local letters = {"M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I"};
    local values = {1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1};
    local res = "";

    for i = 1, #values do
        local l = letters[i];
        local v = values[i];
        res = res .. string.rep(l, math.floor(n / v));
        n = n % v;
    end

    return res;
end

function sortOnTerrID(a, b)
    print(a.TerrID, b.TerrID);
    if a.TerrID <= b.TerrID then 
        return false; 
    else 
        return true; 
    end 
end