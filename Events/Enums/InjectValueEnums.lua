require("Enums.EventEnums");
require("Enums.TriggerEnums");

InjectValueEnum = {
    -- Constants
    INTEGER_CONSTANT = 401,
    NUMBER_CONSTANT = 402,
    NEUTRAL_PLAYER = 403,
    -- Trigger territory
    TRIGGER_TERR_OWNER = 1,
    TRIGGER_TERR_NAME = 2,
    TRIGGER_TERR_NUM_ARMIES = 3,
    TRIGGER_TERR_NUM_SPECIAL_UNITS = 4,
    TRIGGER_TERR_DEFENSE_POWER = 5,
    TRIGGER_TERR_ATTACK_POWER = 6,
    TRIGGER_TERR_STRUCTURE_COUNT = 7,
    -- Deploy order
    DEPLOY_NUM_DEPLOYED = 100,
    -- Attack/transfer order
    MOVE_ORDER_PLAYER = 200,
    MOVE_ORDER_NUM_ARMIES = 201,
    MOVE_ORDER_NUM_SPECIAL_UNITS = 202,
    MOVE_ORDER_ATTACK_POWER = 203,
    -- Slots
    SLOT_PLAYER = 300,
    -- Calculation
    EXPRESSION = 500,
}

local InjectValueMetaData = {
    [InjectValueEnum.TRIGGER_TERR_OWNER] = {
        Color = "#0000FF",
        Name = "Event territory owner",
        Info = "The name of the player that owns the territory on which the event is placed",
    },
    [InjectValueEnum.TRIGGER_TERR_NAME] = {
        Color = "#59009D",
        Name = "Event territory name",
        Info = "The name of the territory on which the event is placed",
    },
    [InjectValueEnum.TRIGGER_TERR_NUM_ARMIES] = {
        Color = "#FF7D00",
        Name = "Number of armies on event territory",
        Info = "The number of armies that are on the territory on which the event is placed",
    },
    [InjectValueEnum.TRIGGER_TERR_NUM_SPECIAL_UNITS] = {
        Color = "#606060",
        Name = "Number of special units on event territory",
        Info = "The number of special units that are on the territory on which the event is placed",
    },
    [InjectValueEnum.TRIGGER_TERR_DEFENSE_POWER] = {
        Color = "#FF697A",
        Name = "Total defense power on event territory",
        Info = "The value of the total defense power of all units that are on the territory on which the event is placed",
    },
    [InjectValueEnum.TRIGGER_TERR_ATTACK_POWER] = {
        Color = "#00FF8C",
        Name = "Total attack power on event territory",
        Info = "The value of the total attack power of all units that are on the territory on which the event is placed",
    },
    [InjectValueEnum.TRIGGER_TERR_STRUCTURE_COUNT] = {
        Color = "#8EBE57",
        Name = "Number of structures",
        Info = "The number of a specific structure on the event territory",
    },
    [InjectValueEnum.DEPLOY_NUM_DEPLOYED] = {
        Color = "#009B9D",
        Name = "Number of armies deployed",
        Info = "The number of armies deployed on the territory on which the event is placed",
    },
    [InjectValueEnum.MOVE_ORDER_PLAYER] = {
        Color = "#AC0059",
        Name = "attack/transfer player",
        Info = "The player who created and ordered the attack/transfer order"
    },
    [InjectValueEnum.MOVE_ORDER_NUM_ARMIES] = {
        Color = "#FFFF00",
        Name = "Number of armies moved",
        Info = "The number of armies that moved in the attack/transfer order"
    },
    [InjectValueEnum.MOVE_ORDER_NUM_SPECIAL_UNITS] = {
        Color = "#FEFF9B",
        Name = "Number of special units moved",
        Info = "The number of special units that moved in the attack/transfer order"
    },
    [InjectValueEnum.MOVE_ORDER_ATTACK_POWER] = {
        Color = "#B70AFF",
        Name = "Total number of attack power of all moved units",
        Info = "The total number of attack power of all units in the attack/transfer order"
    },
    [InjectValueEnum.SLOT_PLAYER] = {
        Color = "#4EFFFF",
        Name = "player by slot",
        Info = "Any slot name. This is used by the mod to get a player to, for example, change the owner of a territory"
    },
    [InjectValueEnum.INTEGER_CONSTANT] = {
        Color = "#00FF05",
        Name = "Whole number",
        Info = "A whole number"
    },
    [InjectValueEnum.NUMBER_CONSTANT] = {
        Color = "#94652E",
        Name = "Any number",
        Info = "Any number"
    },
    [InjectValueEnum.NEUTRAL_PLAYER] = {
        Color = "#AD7E7E",
        Name = "Neutral",
        Info = "Sets the territory to neutral"
    },
    [InjectValueEnum.EXPRESSION] = {
        Color = "#990024",
        Name = "Expression",
        Info = "Create your own expression. An expression can be anything from a single number to a whole calculation"
    }
}

InjectValueEnum.InjectValueConstraints = {
    [InjectValueEnum.TRIGGER_TERR_OWNER] = {
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.SET_OWNER_EVENT}
    },
    [InjectValueEnum.TRIGGER_TERR_NAME] = {
        EventType = {EventTypeEnum.MESSAGE_EVENT}
    },
    [InjectValueEnum.TRIGGER_TERR_NUM_ARMIES] = {
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.TRIGGER_TERR_NUM_SPECIAL_UNITS] = {
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.TRIGGER_TERR_DEFENSE_POWER] = {
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.TRIGGER_TERR_ATTACK_POWER] = {
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.TRIGGER_TERR_STRUCTURE_COUNT] = {
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.DEPLOY_NUM_DEPLOYED] = {
        TriggerType = TriggerTypeEnum.ON_DEPLOY,
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.MOVE_ORDER_PLAYER] = {
        TriggerType = TriggerTypeEnum.ON_MOVE,
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.SET_OWNER_EVENT},
    },
    [InjectValueEnum.MOVE_ORDER_NUM_ARMIES] = {
        TriggerType = TriggerTypeEnum.ON_MOVE,
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.MOVE_ORDER_NUM_SPECIAL_UNITS] = {
        TriggerType = TriggerTypeEnum.ON_MOVE,
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.MOVE_ORDER_ATTACK_POWER] = {
        TriggerType = TriggerTypeEnum.ON_MOVE,
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.SLOT_PLAYER] = {
        EventType = {EventTypeEnum.MESSAGE_EVENT, EventTypeEnum.SET_OWNER_EVENT}
    },
    [InjectValueEnum.INTEGER_CONSTANT] = {
        EventType = {EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.NUMBER_CONSTANT] = {
        EventType = {EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    },
    [InjectValueEnum.NEUTRAL_PLAYER] = {
        EventType = {EventTypeEnum.SET_OWNER_EVENT}
    },
    [InjectValueEnum.EXPRESSION] = {
        EventType = {EventTypeEnum.ADD_ARMIES_EVENT, EventTypeEnum.ADD_STRUCTURES_EVENT, EventTypeEnum.INCOME_MODIFICATION_EVENT}
    }
};

function InjectValueEnum.ValueIsCompatible(event, enum)
    local t = InjectValueEnum.InjectValueConstraints[enum];
    return (t.EventType == nil or valueInTable(t.EventType, event.Type)) and (t.TriggerType == nil or event.CompatibleTriggerType == 0 or t.TriggerType == event.CompatibleTriggerType);
end

---Returns the name of the value enum
---@param type ValueEnum
---@return string
function InjectValueEnum.GetValueTypeName(type)
    return InjectValueMetaData[type].Name;
end

---Returns the info text of the value enum
---@param type ValueEnum
---@return string
function InjectValueEnum.getValueTypeInfo(type)
    return InjectValueMetaData[type].Info;
end

---Returns the color text of the value enum
---@param type ValueEnum
---@return string
function InjectValueEnum.GetValueTypeColor(type)
    return InjectValueMetaData[type].Color;
end

function InjectValueEnum.GetAllInjectValues()
    local l = {};
    for _, v in pairs(InjectValueEnum) do
        if type(v) == "number" then
            table.insert(l, v);
        end
    end
    return l;
end