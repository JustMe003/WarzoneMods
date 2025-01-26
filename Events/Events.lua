---@class UTIL # Contains enums
---@field TriggerTypes table<TriggerTypeName, TriggerTypeEnum>
---@field EventTypes table<EventTypeName, EventTypeEnum>
---@field TriggerMetaData table<TriggerTypeEnum, MetaData>
---@field EventMetaData table<EventTypeEnum, MetaData>
---@field InjectValues table<ValueName, ValueEnum>
---@field InjectValuesConstraints table<ValueEnum, InjectValueConstraint>
---@field InjectValuesMetaData table<ValueEnum, MetaData>
---@field OperatorTypes table<OperatorName, OperatorEnum>

---@alias TriggerTypeName string
---@alias EventTypeName string
---@alias ValueName string

---@alias TriggerTypeEnum integer
---@alias EventTypeEnum integer
---@alias ValueEnum integer

---@class MetaData
---@field Color string # String of format "#XXXXXX", with X being a hex value
---@field Name string # The name of the type
---@field Info string # The info text of the type

---@class Trigger # The parent class of a Trigger
---@field ID TriggerID # The unique identifier of the trigger
---@field Name string # Name of the trigger
---@field Type TriggerTypeEnum # The type of the trigger
---@field Slots integer[]? # The slots that can trigger this trigger
---@field BlacklistSlots boolean? # If true, slots in Slots are blacklisted, otherwise they are whitelisted
---@field NeutralCanFireThis boolean? # If true, a neutral territory can make this trigger fire
---@field Cooldown integer? # The number of turns before this trigger can be fired again
---@field Chance number? # Number between [0-1) that determines whether this trigger fires or not
---@field NumArmies MinMaxObject? # The minimum and maximum number of armies that can make this trigger fire
---@field NumSpecialUnits MinMaxObject? # The minimum and maximum number of special units that can make this trigger fire
---@field DefensePower MinMaxObject? # The minimum and maximum defense power of the territory
---@field AttackPower MinMaxObject? # The minimum and maximum attack power of the territory
---@field Structures table<integer, MinMaxObject>? # The minimum and maximum of each structure

---@class OnDeploy : Trigger # Trigger for deployment orders
---@field NumDeployed MinMaxObject? # The minimum and maximum number of armies deployed

---@class OnMove : Trigger # Trigger for attack / transfer orders
---@field AttackerSlots integer[]? # The slots that can fire this trigger
---@field BlacklistAttackerSlots boolean? # If true, slots in AttackerSlots are blacklisted, otherwise they are whitelisted
---@field NumAttackerArmies MinMaxObject? # The minimum and maximum number of armies that are attacking
---@field NumAttackerSpecialUnits MinMaxObject? # The minimum and maximum number of special units that are attacking
---@field AttackersAttackPower MinMaxObject? # The minimum and maximum attack power of the attacking armies
---@field MustBeSuccessful boolean? # If true, the attack / transfer must be successful, otherwise not
---@field MustNotBeSuccessful boolean? # If true, the attack / transfer must not be successful, otherwise not
---@field MustBeAttack boolean? # If true, the order must be an attack
---@field MustBeTransfer boolean? # If true, the order must be a transfer

---@class OnTurnEnd : Trigger # Trigger that will always try to fire at the end of the turn

---@class ManualTrigger : Trigger # Trigger that can only be triggered by an Event

---@class OnStructureChange : Trigger # Trigger for modifications to structures
---@field StructureChanges table<integer, MinMaxObject>? # The minimum and maximum change to fire this trigger

---@alias TriggerID integer

---@class MinMaxObject # An object that has the fields Minimum and Maximum
---@field Minimum integer? # The minimum
---@field Maximum integer? # The maximum


---@class Event # The parent class for an event
---@field Name string # Name of the event
---@field Type EventTypeEnum # The event type
---@field ID EventID # The ID of the event
---@field CompatibleTriggerType `0` | TriggerTypeEnum # If set, the event can use data that fired the trigger. If not, the event can be used by any trigger but cannot use any trigger data specifically

---@class MessageEvent : Event # Event that sends a message to players
---@field Message SubMessage[] # The text to be send
---@field Receivers integer[] # The slots that will receive the message
---@field BroadcastMessage boolean? # If true, everyone will receive the message. Otherwise only the slots in Receivers will

---@alias SubMessage string | ValueEnum

---@class SetOwnerEvent : Event # Event that changes the owner of the territory
---@field NewOwner ValueEnum # The slot that will become the new owner

---@class AddArmiesEvent : Event # Event that changes the number of armies on the territory
---@field Addition ValueTable | Expression # The number of armies added or subtracted

---@class Expression
---@field Operator OperatorEnum
---@field Left Expression | ValueTable
---@field Right Expression | ValueTable

---@alias OperatorEnum integer
---@alias OperatorName string

---@class ValueTable
---@field Type ValueEnum
---@field Value number?
---@field Input UIObject?

---@class AddStructuresEvent : Event # Event that changes the number of structures on the territory
---@field Addition table<integer, Expression | ValueTable> # The number of structures to be added or removed

---@class IncomeModificationEvent : Event # Event that adds an income modification for a player
---@field PlayerID ValueTable # The player receiving the income modification
---@field Addition ValueTable | Expression # The amount of income added or removed
            --- Local deployment?

---@class FireManualTrigger : Event # Tries to fire a ManualTrigger trigger
---@field TerritoryID integer # The ID of the territory with the trigger
---@field Trigger TriggerID # The ID of the ManualTrigger

---@alias EventID integer

---@class ListItem
---@field Name string # The name of the item
---@field Action fun() # The action that is executed when the item is chosen
---@field Info string # The extra added information of the item

---@class INFO # Struct containing all the additional information text
---@field CooldownCondition string # Cooldown condition
---@field ChanceCondition string # Chance condition
---@field MinimumNumberOfArmiesCondition string # Minimum number of armies condition
---@field MaximumNumberOfArmiesCondition string # Maximum number of armies condition

---@class InjectValueConstraint
---@field EventType integer[] | nil
---@field TriggerType integer[] | nil


INFO = {
    OnDeployTrigger = "This trigger will only be notified when a player deploys on the territory the trigger is assigned to";
    OnMoveTrigger = "This trigger will only be notified when a player transfers or attacks the territory the trigger is assigned to";
    OnTurnEndTrigger = "This trigger will always be notified when at the end of every turn";
    ManualTrigger = "This trigger can only be notified by a event";
    
    MessageEvent = "This event will add an order only displaying a message. This message can be send to everyone, or to certain players only. It is always visible for everyone who can see the territory";
    SetOwnerEvent = "This event will set the owner of the territory to a specific player. The player can be a pre-determined slot, or a player that contributed in firing the trigger (and thus this event)";
    AddArmiesEvent = "This event will allow you to modify the armies on the territory";
    AddStructuresEvent = "This event will allow you to modify the structures on the territory";
    IncomeModificationEvent = "This event will add an income modification for a player. This player can be an pre-determined slot or a player that contributed in firing the trigger (and thus this event)";
    FireManualTrigger = "This event will notify a manual trigger. This event is meant to create custom events on different a different territory. See the examples for to see what use cases this event has";
    OnStructureChange = "This trigger will only be notified when the territory it is assigned to gets a change in its structures";
    
    TriggerName = "This is the name of the trigger. This name is mainly used for you to distinguish this trigger easily between all other created triggers";
    TriggerSlots = "In this subwindow you can select slots. The player controlling the trigger territory must either be one of the slots, or none of the slots, depending on the \"Only non-included slots can fire this trigger\" setting.";
    TriggerStructures = "In this subwindow you can add/remove conditions based on the structures on the trigger territory.";
    TriggerBlacklistSlots = "When not checked, the player controlling the trigger territory must be one of the selected slots. Otherwise the player controlling the trigger territory must be none of the selected slots";
    TriggerFireIfNeutral = "When checked, this trigger can fire when the territory is controlled by neutral. Otherwise the trigger cannot fire if the territory is controlled by neutral";
    CooldownCondition = "This condition acts as a cooldown. The number entered represents the number of turns needed to pass before this trigger can be triggered again.\nWhen a trigger which has a cooldown of 3 turns is triggered, it cannot be triggered again in the following 3 turns.\nA cooldown of 0 turns has the same behaviour as no cooldown",
    ChanceCondition = "This condition adds some random behaviour to a trigger. The value of this condition is in percentages: 100 means this trigger will always be triggered, 50 means this trigger will only trigger half of the time, etc.\nNote that a trigger can only trigger if ALL conditions are met, this condition is meant to add some irregularity to a trigger";
    MinimumNumberOfArmiesCondition = "This condition is met when there are at least a certain number of armies on the trigger territory.\nIf this condition is set to 8, this condition is met when there are 8 or more armies on the trigger territory.\nNote that this condition only tests the number of armies on the trigger territory, there are other constraints for defence power, attack power, number of special units, etc.";
    MaximumNumberOfArmiesCondition = "This condition is met when there are at most a certain number of armies on the trigger territory.\nIf this condition is set to 8, this condition is met when there are 8 or less armies on the trigger territory.\nNote that this condition only tests the number of armies on the trigger territory, there are other constraints for defence power, attack power, number of special units, etc.";
    MinimumNumberOfSpecialUnitsCondition = "This condition is met when there are at least a certain number of special units on the trigger territory.\nIf this condition is set to 1 for example, this is condition is met when there are 1 or more special units on the trigger territory.\nNote that this condition only depends on the number of special units";
    MaximumNumberOfSpecialUnitsCondition = "This condition is met when there are at most a certain number of special units on the trigger territory.\nIf this condition is set to 3 for example, this is condition is met when there are 3 or less special units on the trigger territory.\nNote that this condition only depends on the number of special units";
    MinimumDefensePowerCondition = "This condition is met when the total defense power of all armies and special units combined is at least a certain number.\nDefense power is the number that is multiplied with the defensive killrate to calculate how many armies are killed when defending";
    MaximumDefensePowerCondition = "This condition is met when the total defense power of all armies and special units combined is at most a certain number.\nDefense power is the number that is multiplied with the defensive killrate to calculate how many armies are killed when defending";
    MinimumAttackPowerCondition = "This condition is met when the total attack power of all armies and special units combined is at least a certain number.\nAttack power is the number that is multiplied with the attacking killrate to calculate how many armies are killed when attacking";
    MaximumAttackPowerCondition = "This condition is met when the total attack power of all armies and special units combined is at most a certain number.\nAttack power is the number that is multiplied with the attacking killrate to calculate how many armies are killed when attacking";
    MinimumArmiesDeployedCondition = "This condition is met when the number of armies deployed is at least a certain number.\nIf this condition is set to 5, this condition is met if the deployment order deploys 5 or more armies.\nNote that this only takes the new deployed armies into account, nothing else";
    MaximumArmiesDeployedCondition = "This condition is met when the number of armies deployed is at most a certain number.\nIf this condition is set to 15, this condition is met if the deployment order deploys 15 or less armies.\nNote that this only takes the new deployed armies into account, nothing else";
    TriggerAttackerSlots = "In this subwindow you can select slots. The player attacking the trigger territory must either be one of the slots, or none of the slots, depending on the \"Only non-included attacker slots can fire this trigger\" setting.";
    TriggerBlacklistAttackerSlots = "When not checked, the player attacking the trigger territory must be one of the selected slots. Otherwise the player attacking the trigger territory must be none of the selected slots";
    TriggerMustBeSuccessful = "When checked, the attack/transfer must be successful. Generally a transfer is always successful, an attack not. When not checked, it does NOT matter whether the attack/transfer was successful or not\nCannot be used in combination with \"Must not be successful\"";
    TriggerMustNotBeSuccessful = "When checked, the attack/transfer must NOT be successful. Generally a transfer is always successful, an attack not. When not checked, it does NOT matter whether the attack/transfer was successful or not\nCannot be used in combination with \"Must be successful\"";
    TriggerMustBeAttack = "When checked, the attack/transfer must be an attack. When not checked, it does not matter whether it is an attack or transfer\nCannot be used in combination with \"Must be transfer\"";
    TriggerMustBeTransfer = "When checked, the attack/transfer must be a transfer. When not checked, it does not matter whether it is an attack or transfer\nCannot be used in combination with \"Must be attack\"";
    MinimumNumberOfAttackingArmiesCondition = "This condition is met when the number of armies that attack is at least a certain number.\nIf this condition is set to 5, this condition is met if the attackers attack with 5 or more armies.\nNote that this only takes the number of normal attacking armies into account, nothing else";
    MaximumNumberOfAttackingArmiesCondition = "This condition is met when the number of armies that attack is at most a certain number.\nIf this condition is set to 15, this condition is met if the attackers attack with 15 or less armies.\nNote that this only takes the number of normal attacking armies into account, nothing else";
    MinimumNumberOfAttackingSpecialUnitsCondition = "This condition is met when the number of special units that attack at least a certain number.\nIf this condition is set to 1, this condition is met if the attacking armies includes 1 or more special units.\nNote that this only takes the number of attacking special units into account, nothing else";
    MaximumNumberOfAttackingSpecialUnitsCondition = "This condition is met when the number of special units that attack at most a certain number.\nIf this condition is set to 3, this condition is met if the attacking armies includes 3 or less special units.\nNote that this only takes the number of attacking special units into account, nothing else";
    MinimumAttackersAttackPowerCondition = "This condition is met when the attackers attack power is at least a certain number.\nAttack power is the number that is multiplied with the attacking killrate to calculate how many armies are killed when attacking";
    MaximumAttackersAttackPowerCondition = "This condition is met when the attackers attack power is at most a certain number.\nAttack power is the number that is multiplied with the attacking killrate to calculate how many armies are killed when attacking";
    MinimumStructuresOnTerritoryString = "This condition is met when there are at least a certain number of {STRUCT}s structures on the trigger territory. When this is set to 2 {STRUCT}s, this condition is met when there are 2 or more {STRUCT}s on the territory";
    MaximumStructuresOnTerritoryString = "This condition is met when there are at most a certain number of {STRUCT}s structures on the trigger territory. When this is set to 3 {STRUCT}s, this condition is met when there are 3 or less {STRUCT}s on the territory";
    MinimumStructuresChangeString = "This condition allows you to trigger events when a certain amount of {STRUCT}s structures are added or removed from the territory.\n\nFor example, when set to -2, the condition is met when there are 2 or more {STRUCT}s REMOVED from the territory.\n\nWhen set to 2, the condition is met when there are 2 or more {STRUCT}s ADDED to the territory";
    MaximumStructuresChangeString = "This condition allows you to trigger events when a certain amount of {STRUCT}s structures are added or removed from the territory.\n\nFor example, when set to -2, the condition is met when there are 2 or less {STRUCT}s REMOVED from the territory.\n\nWhen set to 2, the condition is met when there are 2 or less {STRUCT}s ADDED to the territory";

    EventName = "This is the name of the event. This name is mainly used for you to distinguish an event easily between all other events",
    EventBroadcastMessage = "When checked, everybody will see this message. When not checked, only the players with vision on the event territory and those manually included will see the message",
    EventMessageReceivers = "Additional players (slots) that will always receive the message. Does nothing if the broadcast setting is checked",
    EventMessage = "Piece your own custom message together. The text inputs are fixed, in the sense that everything put there will by shown exactly as you put it. The values are the way to \"inject\" any game data in the message. They will be replaced by their respective value when the message is shown";
    EventNewOwner = "Select the new owner of the territory. If you want a specific player, you have to select that player by inputting his slot",
    EventAddArmies = "Here you can create your own expression to determine how many armies will be added/removed from the event territory. This can be a simple number like 10, or you can make it so that 10% of the current armies are added to the territory. Note that the expression is calculated from TOP to BOTTOM, with priority given to expressions in brackets '()'",
    EventStructureModification = "Here you can configure how many structures of what type are added/removed. Note that a structure count can be set to negative. You can create an expression for each structure individually.",
    EventIncomeModDuration = "The amount of turns this income modification will last. When set to 5 for example, once the event has happened, the player will receive additional income for 5 turn from then. The value 0 indicates that the income modification will last until the end of the game. If the event happens again when the income modification is still in play, it will be stacked.",
    EventSelectManualTrigger = "You must select which trigger will be notified by this event, alongside the territory. This is necessary since a territory can have multiple manual triggers",
    EventSelectTerritory = "You must select a territory, that in turn has a manual trigger. Together with the linked manual trigger, the mod will know which trigger to notify. This is needed, since a territory can have multiple manual triggers assigned to it",

    ValueTriggerTerrOwner = "The name of the player that owns the territory on which the event is placed",
    ValueTriggerTerrName = "The name of the territory on which the event is placed",
    ValueTriggerTerrNumArmies = "The number of armies that are on the territory on which the event is placed",
    ValueTriggerTerrNumSpecialUnits = "The number of special units that are on the territory on which the event is placed",
    ValueTriggerTerrDefensePower = "The value of the total defense power of all units that are on the territory on which the event is placed",
    ValueTriggerTerrAttackPower = "The value of the total attack power of all units that are on the territory on which the event is placed",
    ValueTriggerTerrStructureCount = "The number of a specific structure on the event territory";
    ValueNumDeployed = "The number of armies deployed on the territory on which the event is placed",
    ValueMovePlayer = "The player who created and ordered the attack/transfer order",
    ValueMoveNumArmies = "The number of armies that moved in the attack/transfer order",
    ValueMoveNumSpecialUnits = "The number of special units that moved in the attack/transfer order",
    ValueMoveAttackPower = "The total number of attack power of all units in the attack/transfer order",
    ValueSlotPlayer = "Any slot name. This is used by the mod to get a player to, for example, change the owner of a territory",
    ValueIntegerConstant = "A whole number",
    ValueNumberConstant = "Any number",
    ValueNeutralPlayer = "Sets the territory to neutral",
    ValueExpression = "Create your own expression. An expression can be anything from a single number to a whole calculation",

    SlotNameFormat = "The slot name must contain only letters A-Z, you don't need to write the word 'slot' before it",

    OperatorAddition = "+ operator. Adds the 2 numbers together (5 + 3 = 8)",
    OperatorMinus = "- operator. Subtracts the right number from the left number (8 - 3 = 5)",
    OperatorMultiplication = "x operator. Multiplies the 2 numbers (3 * 4 = 12)",
    OperatorDivision = "/ operator. Divides the left number by the right number (12 / 4 = 3)",
    OperatorModulus = "% operator. The remainder of dividing the left number by the right number (7 % 2 = 1, 11 % 3 = 2, 10 % 20 = 10)",
    OperatorBrackets = "Not really an operator. This will add an expression in between '(' and ')', which is calculated first before other parts",

    AssignSelectEvents = "Select events that happen after the trigger has fired. A trigger is combined with one or multiple events to create and assigned to one or multiple territories. Then, during the game, when the trigger fires, it will play all events.",
}

UTIL = {
    TriggerTypes = {
        OnDeploy = 1,
        OnMove = 2,
        OnTurnEnd = 3,
        ManualTrigger = 4,
        OnStructureChange = 5
    },
    EventTypes = {
        MessageEvent = 1,
        SetOwnerEvent = 2,
        AddArmiesEvent = 3,
        AddStructuresEvent = 4,
        IncomeModificationEvent = 5,
        FireManualTrigger = 6
    },
    InjectValues = {
        -- Constants
        IntegerConstant = 401,
        NumberConstant = 402,
        NeutralPlayer = 403,
        -- Trigger territory
        TriggerTerrOwner = 1,
        TriggerTerrName = 2,
        TriggerTerrNumArmies = 3,
        TriggerTerrNumSpecialUnits = 4,
        TriggerTerrDefensePower = 5,
        TriggerTerrAttackPower = 6,
        TriggerTerrStructureCount = 7,
        -- Deploy order
        DeployNumDeployed = 100,
        -- Attack/transfer order
        MoveOrderPlayer = 200,
        MoveOrderNumArmies = 201,
        MoveOrderNumSpecialUnits = 202,
        MoveOrderAttackPower = 203,
        -- Slots
        SlotPlayer = 300,
        -- Calculation
        Expression = 500,
    },
    OperatorTypes = {
        Addition = 1,
        Minus = 2,
        Multiplication = 3,
        Division = 4,
        Modulus = 5,
        Brackets = 6,
    }
};

UTIL.TriggerMetaData = {
    [UTIL.TriggerTypes.OnDeploy] = {
        Color = "#0000FF", 
        Name = "Deployment trigger", 
        Info = INFO.OnDeployTrigger
    },
    [UTIL.TriggerTypes.OnMove] = {
        Color = "#59009D", 
        Name = "Attack/transfer trigger", 
        Info = INFO.OnMoveTrigger
    },
    [UTIL.TriggerTypes.OnTurnEnd] = {
        Color = "#009B9D", 
        Name = "Turn end trigger", 
        Info = INFO.OnTurnEndTrigger
    },
    [UTIL.TriggerTypes.ManualTrigger] = {
        Color = "#AC0059",
        Name = "Manual trigger", 
        Info = INFO.ManualTrigger
    },
    [UTIL.TriggerTypes.OnStructureChange] = {
        Color = "#B70AFF",
        Name = "Structures change trigger", 
        Info = INFO.OnStructureChange
    },
};

UTIL.EventMetaData = {
    [UTIL.EventTypes.MessageEvent] = {
        Color = "#C04000",
        Name = "Message event",
        Info = INFO.MessageEvent
    },
    [UTIL.EventTypes.SetOwnerEvent] = {
        Color = "#94652E",
        Name = "Set owner event",
        Info = INFO.SetOwnerEvent
    },
    [UTIL.EventTypes.AddArmiesEvent] = {
        Color = "#AD7E7E",
        Name = "Modify armies event",
        Info = INFO.AddArmiesEvent
    },
    [UTIL.EventTypes.AddStructuresEvent] = {
        Color = "#8EBE57",
        Name = "Modify structures event",
        Info = INFO.AddStructuresEvent
    },
    [UTIL.EventTypes.IncomeModificationEvent] = {
        Color = "#FFAF56",
        Name = "Income modification event",
        Info = INFO.IncomeModificationEvent
    },
    [UTIL.EventTypes.FireManualTrigger] = {
        Color = "#4169E1",
        Name = "Fire manual trigger",
        Info = INFO.FireManualTrigger
    }
};

UTIL.InjectValuesConstraints = {
    [UTIL.InjectValues.TriggerTerrOwner] = {
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.SetOwnerEvent}
    },
    [UTIL.InjectValues.TriggerTerrName] = {
        EventType = {UTIL.EventTypes.MessageEvent}
    },
    [UTIL.InjectValues.TriggerTerrNumArmies] = {
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent}
    },
    [UTIL.InjectValues.TriggerTerrNumSpecialUnits] = {
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent}
    },
    [UTIL.InjectValues.TriggerTerrDefensePower] = {
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent}
    },
    [UTIL.InjectValues.TriggerTerrAttackPower] = {
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent}
    },
    [UTIL.InjectValues.TriggerTerrStructureCount] = {
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent}
    },
    [UTIL.InjectValues.DeployNumDeployed] = {
        TriggerType = UTIL.TriggerTypes.OnDeploy,
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent},
    },
    [UTIL.InjectValues.MoveOrderPlayer] = {
        TriggerType = UTIL.TriggerTypes.OnMove,
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.SetOwnerEvent},
    },
    [UTIL.InjectValues.MoveOrderNumArmies] = {
        TriggerType = UTIL.TriggerTypes.OnMove,
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent},
    },
    [UTIL.InjectValues.MoveOrderNumSpecialUnits] = {
        TriggerType = UTIL.TriggerTypes.OnMove,
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent},
    },
    [UTIL.InjectValues.MoveOrderAttackPower] = {
        TriggerType = UTIL.TriggerTypes.OnMove,
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent},
    },
    [UTIL.InjectValues.SlotPlayer] = {
        EventType = {UTIL.EventTypes.MessageEvent, UTIL.EventTypes.SetOwnerEvent}
    },
    [UTIL.InjectValues.IntegerConstant] = {
        EventType = {UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent}
    },
    [UTIL.InjectValues.NumberConstant] = {
        EventType = {UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent}
    },
    [UTIL.InjectValues.NeutralPlayer] = {
        EventType = {UTIL.EventTypes.SetOwnerEvent}
    },
    [UTIL.InjectValues.Expression] = {
        EventType = {UTIL.EventTypes.AddArmiesEvent, UTIL.EventTypes.AddStructuresEvent, UTIL.EventTypes.IncomeModificationEvent}
    }
};

UTIL.InjectValuesMetaData = {
    [UTIL.InjectValues.TriggerTerrOwner] = {
        Color = "#0000FF",
        Name = "Event territory owner",
        Info = INFO.ValueTriggerTerrOwner
    },
    [UTIL.InjectValues.TriggerTerrName] = {
        Color = "#59009D",
        Name = "Event territory name",
        Info = INFO.ValueTriggerTerrName
    },
    [UTIL.InjectValues.TriggerTerrNumArmies] = {
        Color = "#FF7D00",
        Name = "Number of armies on event territory",
        Info = INFO.ValueTriggerTerrNumArmies
    },
    [UTIL.InjectValues.TriggerTerrNumSpecialUnits] = {
        Color = "#606060",
        Name = "Number of special units on event territory",
        Info = INFO.ValueTriggerTerrNumSpecialUnits
    },
    [UTIL.InjectValues.TriggerTerrDefensePower] = {
        Color = "#FF697A",
        Name = "Total defense power on event territory",
        Info = INFO.ValueTriggerTerrDefensePower
    },
    [UTIL.InjectValues.TriggerTerrAttackPower] = {
        Color = "#00FF8C",
        Name = "Total attack power on event territory",
        Info = INFO.ValueTriggerTerrAttackPower
    },
    [UTIL.InjectValues.TriggerTerrStructureCount] = {
        Color = "#8EBE57",
        Name = "Number of structures",
        Info = INFO.ValueTriggerTerrStructureCount
    },
    [UTIL.InjectValues.DeployNumDeployed] = {
        Color = "#009B9D",
        Name = "Number of armies deployed",
        Info = INFO.ValueNumDeployed
    },
    [UTIL.InjectValues.MoveOrderPlayer] = {
        Color = "#AC0059",
        Name = "attack/transfer player",
        Info = INFO.ValueMovePlayer
    },
    [UTIL.InjectValues.MoveOrderNumArmies] = {
        Color = "#FFFF00",
        Name = "Number of armies moved",
        Info = INFO.ValueMoveNumArmies
    },
    [UTIL.InjectValues.MoveOrderNumSpecialUnits] = {
        Color = "#FEFF9B",
        Name = "Number of special units moved",
        Info = INFO.ValueMoveNumSpecialUnits
    },
    [UTIL.InjectValues.MoveOrderAttackPower] = {
        Color = "#B70AFF",
        Name = "Total number of attack power of all moved units",
        Info = INFO.ValueMoveAttackPower
    },
    [UTIL.InjectValues.SlotPlayer] = {
        Color = "#4EFFFF",
        Name = "player by slot",
        Info = INFO.ValueSlotPlayer
    },
    [UTIL.InjectValues.IntegerConstant] = {
        Color = "#00FF05",
        Name = "Whole number",
        Info = INFO.ValueIntegerConstant
    },
    [UTIL.InjectValues.NumberConstant] = {
        Color = "#94652E",
        Name = "Any number",
        Info = INFO.ValueNumberConstant
    },
    [UTIL.InjectValues.NeutralPlayer] = {
        Color = "#AD7E7E",
        Name = "Neutral",
        Info = INFO.ValueNeutralPlayer
    },
    [UTIL.InjectValues.Expression] = {
        Color = "#990024",
        Name = "Expression",
        Info = INFO.ValueExpression
    }
}

---Returns the minimum and maximum info text of the option
---@param field "Structures" | "StructuresChanges" # Name of the field
---@return table<string, string> # Table with both min and max info string
function getStructuresInfoText(field)
    if field == "Structures" then
        return {
            Minimum = INFO.MinimumStructuresOnTerritoryString;
            Maximum = INFO.MaximumStructuresOnTerritoryString;
        };
    else
        return {
            Minimum = INFO.MinimumStructuresChangeString;
            Maximum = INFO.MaximumStructuresChangeString;
        };
    end
end

---Creates a new trigger
---@param triggers table<number, Trigger> # The triggers created so far
---@param type TriggerTypeEnum # The type of the new trigger
---@return Trigger
function createNewTrigger(triggers, type)
    local newID = getHighestID(triggers) + 1;
    ---@type Trigger
    local t = {
        Type = type,
        Name = "New trigger #" .. newID,
        ID = newID
    };
    return t;
end

---Creates a new event
---@param events table<number, Event> # The events created so far
---@param type any
---@return Event
function createNewEvent(events, type)
    local newID = getHighestID(events) + 1;
    ---@type Event
    local t = {
        Type = type,
        Name = "New Event #" .. newID,
        ID = newID,
        CompatibleTriggerType = 0
    };
    return t;
end

---Returns the highest ID in the list
---@param list table<any, table>
---@return integer
function getHighestID(list)
    local id = 0;
    for _, t in pairs(list) do
        id = math.max(id, t.ID);
    end
    return id;
end

---Saves the trigger
---@param trigger Trigger
---@param inputs table
function saveTrigger(trigger, inputs)
    if inputs.Name ~= nil then trigger.Name = inputs.Name.GetText(); end
    if inputs.BlacklistSlots ~= nil then trigger.BlacklistSlots = inputs.BlacklistSlots.GetIsChecked(); end
    if inputs.NeutralCanFireThis ~= nil then trigger.NeutralCanFireThis = inputs.NeutralCanFireThis.GetIsChecked(); end
    if inputs.Cooldown ~= nil then trigger.Cooldown = inputs.Cooldown.GetValue(); end
    if inputs.Chance ~= nil then trigger.Chance = inputs.Chance.GetValue(); end
    if inputs.NumArmies ~= nil then
        trigger.NumArmies = trigger.NumArmies or {};
        if inputs.NumArmies.Minimum ~= nil then trigger.NumArmies.Minimum = inputs.NumArmies.Minimum.GetValue(); end
        if inputs.NumArmies.Maximum ~= nil then trigger.NumArmies.Maximum = inputs.NumArmies.Maximum.GetValue(); end
    end
    if inputs.NumSpecialUnits ~= nil then
        trigger.NumSpecialUnits = trigger.NumSpecialUnits or {};
        if inputs.NumSpecialUnits.Minimum ~= nil then trigger.NumSpecialUnits.Minimum = inputs.NumSpecialUnits.Minimum.GetValue(); end
        if inputs.NumSpecialUnits.Maximum ~= nil then trigger.NumSpecialUnits.Maximum = inputs.NumSpecialUnits.Maximum.GetValue(); end
    end
    if inputs.DefensePower ~= nil then
        trigger.DefensePower = trigger.DefensePower or {};
        if inputs.DefensePower.Minimum ~= nil then trigger.DefensePower.Minimum = inputs.DefensePower.Minimum.GetValue(); end
        if inputs.DefensePower.Maximum ~= nil then trigger.DefensePower.Maximum = inputs.DefensePower.Maximum.GetValue(); end
    end
    if inputs.AttackPower ~= nil then
        trigger.AttackPower = trigger.AttackPower or {};
        if inputs.AttackPower.Minimum ~= nil then trigger.AttackPower.Minimum = inputs.AttackPower.Minimum.GetValue(); end
        if inputs.AttackPower.Maximum ~= nil then trigger.AttackPower.Maximum = inputs.AttackPower.Maximum.GetValue(); end
    end
    local t = {
        [UTIL.TriggerTypes.OnDeploy] = saveOnDeployTrigger,
        [UTIL.TriggerTypes.OnMove] = saveOnMoveTrigger,
        [UTIL.TriggerTypes.OnTurnEnd] = saveOnTurnEndTrigger,
        [UTIL.TriggerTypes.ManualTrigger] = saveManualTrigger,
        [UTIL.TriggerTypes.OnStructureChange] = saveOnStructureChange
    }
    ---@diagnostic disable-next-line: param-type-mismatch
    t[trigger.Type](trigger, inputs);

    removeEmptyTables(trigger)
end

---Saves a OnDeploy trigger
---@param trigger OnDeploy
---@param inputs table
function saveOnDeployTrigger(trigger, inputs)
    if inputs.NumDeployed ~= nil then
        trigger.NumDeployed = trigger.NumDeployed or {};
        if inputs.NumDeployed.Minimum ~= nil then trigger.NumDeployed.Minimum = inputs.NumDeployed.Minimum.GetValue(); end
        if inputs.NumDeployed.Maximum ~= nil then trigger.NumDeployed.Maximum = inputs.NumDeployed.Maximum.GetValue(); end
    end
end

---Saves a OnMove trigger
---@param trigger OnMove
---@param inputs table
function saveOnMoveTrigger(trigger, inputs)
    if inputs.BlacklistAttackerSlots ~= nil then trigger.BlacklistAttackerSlots = inputs.BlacklistAttackerSlots.GetIsChecked(); end
    if inputs.NumAttackerArmies ~= nil then
        trigger.NumAttackerArmies = trigger.NumAttackerArmies or {};
        if inputs.NumAttackerArmies.Minimum ~= nil then trigger.NumAttackerArmies.Minimum = inputs.NumAttackerArmies.Minimum.GetValue(); end
        if inputs.NumAttackerArmies.Maximum ~= nil then trigger.NumAttackerArmies.Maximum = inputs.NumAttackerArmies.Maximum.GetValue(); end
    end
    if inputs.NumAttackerSpecialUnits ~= nil then
        trigger.NumAttackerSpecialUnits = trigger.NumAttackerSpecialUnits or {};
        if inputs.NumAttackerSpecialUnits.Minimum ~= nil then trigger.NumAttackerSpecialUnits.Minimum = inputs.NumAttackerSpecialUnits.Minimum.GetValue(); end
        if inputs.NumAttackerSpecialUnits.Maximum ~= nil then trigger.NumAttackerSpecialUnits.Maximum = inputs.NumAttackerSpecialUnits.Maximum.GetValue(); end
    end
    if inputs.AttackersAttackPower ~= nil then
        trigger.AttackersAttackPower = trigger.AttackersAttackPower or {};
        if inputs.AttackersAttackPower.Minimum ~= nil then trigger.AttackersAttackPower.Minimum = inputs.AttackersAttackPower.Minimum.GetValue(); end
        if inputs.AttackersAttackPower.Maximum ~= nil then trigger.AttackersAttackPower.Maximum = inputs.AttackersAttackPower.Maximum.GetValue(); end
    end
    if inputs.MustBeSuccessful ~= nil then trigger.MustBeSuccessful = inputs.MustBeSuccessful.GetIsChecked(); end
    if inputs.MustNotBeSuccessful ~= nil then trigger.MustNotBeSuccessful = inputs.MustNotBeSuccessful.GetIsChecked(); end
    if inputs.MustBeAttack ~= nil then trigger.MustBeAttack = inputs.MustBeAttack.GetIsChecked(); end
    if inputs.MustBeTransfer ~= nil then trigger.MustBeTransfer = inputs.MustBeTransfer.GetIsChecked(); end
end

---Save a OnTurnEnd trigger
---@param trigger OnTurnEnd
---@param inputs table
function saveOnTurnEndTrigger(trigger, inputs)

end

---Save a ManualTrigger trigger
---@param trigger ManualTrigger
---@param inputs table
function saveManualTrigger(trigger, inputs)

end

---Save a OnStructureChange trigger
---@param trigger OnStructureChange
---@param inputs table
function saveOnStructureChange(trigger, inputs)

end

---Saves the passed Event with the given inputs
---@param event Event
---@param inputs table
function saveEvent(event, inputs)
    if inputs.Name ~= nil then event.Name = inputs.Name.GetText(); end
    local t = {
        [UTIL.EventTypes.MessageEvent] = saveMessageEvent;
        [UTIL.EventTypes.SetOwnerEvent] = saveSetOwnerEvent;
        [UTIL.EventTypes.AddArmiesEvent] = saveAddArmiesEvent;
        [UTIL.EventTypes.AddStructuresEvent] = saveAddStructuresEvent;
        [UTIL.EventTypes.IncomeModificationEvent] = saveIncomeModificationEvent;
        [UTIL.EventTypes.FireManualTrigger] = saveFireManualTriggerEvent;
    }
    t[event.Type](event, inputs);
end

function saveMessageEvent(event, inputs)
    event.BroadcastMessage = inputs.BroadcastMessage.GetIsChecked();

    local triggerType = 0;
    for i, sub in ipairs(inputs.Message) do
        if isValueTable(sub) then
            event.Message[i] = sub;
            saveEventValue(event.Message[i], sub);
            triggerType = UTIL.InjectValuesConstraints[sub.Type].TriggerType or triggerType;
        else
            event.Message[i] = sub.GetText();
        end
    end
    event.CompatibleTriggerType = triggerType;
end

function saveSetOwnerEvent(event, inputs)
    event.NewPlayer = inputs.NewPlayer;
    saveEventValue(event.NewPlayer, inputs.NewPlayer);
    if event.NewPlayer then
        event.CompatibleTriggerType = UTIL.InjectValuesConstraints[event.NewPlayer.Type].TriggerType or 0;
    else
        event.CompatibleTriggerType = 0;
    end
end

function saveAddArmiesEvent(event, inputs)
    event.Expression = saveExpression(event.Expression, inputs.Expression or {});
    event.CompatibleTriggerType = getTriggerTypeFromExpression(event.Expression);
end

function saveAddStructuresEvent(event, inputs)
    local triggerType = 0;
    event.Addition = {};
    for enum, input in pairs(inputs.Addition) do
        event.Addition[enum] = saveExpression(event.Addition[enum], input);
        if triggerType == 0 then
            triggerType = getTriggerTypeFromExpression(event.Addition[enum]);
        end
    end
    event.CompatibleTriggerType = triggerType;
end

function saveIncomeModificationEvent(event, inputs)
    event.Duration = inputs.Duration.GetValue();
    event.Player = inputs.Player;
    saveEventValue(event.Player, inputs.Player);
    event.IncomeMod = saveExpression(event.IncomeMod, inputs.IncomeMod or {});
    if isValueTable(event.Player or {}) then
        event.CompatibleTriggerType = UTIL.InjectValuesConstraints[event.Player.Type].TriggerType or 0;
    else
        event.CompatibleTriggerType = 0;
    end
    if event.CompatibleTriggerType == 0 then
        event.CompatibleTriggerType = getTriggerTypeFromExpression(event.IncomeMod);
    end
end

function saveFireManualTriggerEvent(event, inputs)
    event.TriggerID = inputs.TriggerID;
    event.TerritoryID = inputs.TerritoryID;
end

function saveExpression(data, input)
    if isValueTable(input) then
        data = input;
        saveEventValue(data, input);
        return data;
    elseif isExpression(input) then
        data = {};
        data.Operator = input.Operator;
        data.Left = saveExpression(data.Left, input.Left);
        data.Right = saveExpression(data.Right, input.Right);
        return data;
    else
        return {};
    end
end

function getTriggerTypeFromExpression(data)
    if isValueTable(data) then
        return UTIL.InjectValuesConstraints[data.Type].TriggerType or 0;
    elseif isExpression(data) then
        local left = getTriggerTypeFromExpression(data.Left);
        local right = getTriggerTypeFromExpression(data.Right);
        if left > 0 then
            return left;
        else
            return right;
        end
    end
    return 0;
end

function saveEventValue(data, input)
    if data == nil then return; end
    if data.Type == UTIL.InjectValues.SlotPlayer or data.Type == UTIL.InjectValues.TriggerTerrStructureCount then
        data.Value = input.Value;
    elseif input.Input ~= nil then
        data.Value = input.Input.GetValue();
        data.Input = nil;
    end
end

function isValueTable(t)
    return t.Type ~= nil;
end

function isExpression(t)
    return t.Operator ~= nil;
end

function removeValueFromExpression(data)
    if isValueTable(data) then return {}; end
    if isExpression(data) then
        if isExpression(data.Left) or isValueTable(data.Left) then
            return data.Left;
        end
        return data.Right;
    end
    return {};
end

function removeEmptyTables(t)
    for key, value in pairs(t) do
        if type(value) == "table" then
            if getTableLength(value) == 0 then
                t[key] = nil;
            else
                removeEmptyTables(value);
            end
        end
    end
end

---Removes a field from a trigger
---@param trigger Trigger
---@param field string
function removeFieldFromTrigger(trigger, field)
    trigger[field] = nil;
end

---Generates the condition list based on the trigger type
---@param trigger Trigger
---@param inputs table
---@param selectFun fun(t: Trigger)
---@param close fun()
---@return ListItem
function generateConditionList(trigger, inputs, selectFun, close)
    return {
        trigger.Cooldown == nil and {
            Name = "Cooldown";
            Action = function() 
                saveTrigger(trigger, inputs);
                trigger.Cooldown = 3;
                selectFun(trigger);
                close();
            end;
            Info = INFO.CooldownCondition;
        } or nil;
        
        trigger.Chance == nil and {
            Name = "Chance";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.Chance = 100;
                selectFun(trigger);
                close();
            end;
            Info = INFO.ChanceCondition;
        } or nil;
        (trigger.NumArmies == nil or trigger.NumArmies.Minimum == nil) and {
            Name = "Minimum number of armies";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.NumArmies = trigger.NumArmies or {};
                trigger.NumArmies.Minimum = 5;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MinimumNumberOfArmiesCondition;
        } or nil;
        (trigger.NumArmies == nil or trigger.NumArmies.Maximum == nil) and {
            Name = "Maximum number of armies";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.NumArmies = trigger.NumArmies or {};
                trigger.NumArmies.Maximum = 20;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MaximumNumberOfArmiesCondition;
        } or nil;
        (trigger.NumSpecialUnits == nil or trigger.NumSpecialUnits.Minimum == nil) and {
            Name = "Minimum number of special units";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.NumSpecialUnits = trigger.NumSpecialUnits or {};
                trigger.NumSpecialUnits.Minimum = 1;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MinimumNumberOfSpecialUnitsCondition;
        } or nil;
        (trigger.NumSpecialUnits == nil or trigger.NumSpecialUnits.Maximum == nil) and {
            Name = "Maximum number of special units";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.NumSpecialUnits = trigger.NumSpecialUnits or {};
                trigger.NumSpecialUnits.Maximum = 3;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MinimumNumberOfSpecialUnitsCondition;
        } or nil;
        (trigger.DefensePower == nil or trigger.DefensePower.Minimum == nil) and {
            Name = "Minimum total defense power";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.DefensePower = trigger.DefensePower or {};
                trigger.DefensePower.Minimum = 5;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MinimumDefensePowerCondition;
        } or nil;
        (trigger.DefensePower == nil or trigger.DefensePower.Maximum == nil) and {
            Name = "Maximum total defense power";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.DefensePower = trigger.DefensePower or {};
                trigger.DefensePower.Maximum = 20;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MaximumDefensePowerCondition;
        } or nil;
        (trigger.AttackPower == nil or trigger.AttackPower.Minimum == nil) and {
            Name = "Minimum total attack power";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.AttackPower = trigger.AttackPower or {};
                trigger.AttackPower.Minimum = 5;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MinimumAttackPowerCondition;
        } or nil;
        (trigger.AttackPower == nil or trigger.AttackPower.Maximum == nil) and {
            Name = "Maximum total attack power";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.AttackPower = trigger.AttackPower or {};
                trigger.AttackPower.Maximum = 20;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MaximumAttackPowerCondition;
        } or nil;
        ---@cast trigger OnDeploy
        (trigger.Type == UTIL.TriggerTypes.OnDeploy and (trigger.NumDeployed == nil or trigger.NumDeployed.Minimum == nil)) and {
            Name = "Minimum number of deployed armies";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.NumDeployed = trigger.NumDeployed or {};
                trigger.NumDeployed.Minimum = 5;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MinimumArmiesDeployedCondition;
        } or nil;
        ---@cast trigger OnDeploy
        (trigger.Type == UTIL.TriggerTypes.OnDeploy and (trigger.NumDeployed == nil or trigger.NumDeployed.Maximum == nil)) and {
            Name = "Maximum number of deployed armies";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.NumDeployed = trigger.NumDeployed or {};
                trigger.NumDeployed.Maximum = 20;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MaximumArmiesDeployedCondition;
        } or nil;
        ---@cast trigger OnMove
        (trigger.Type == UTIL.TriggerTypes.OnMove and (trigger.NumAttackerArmies == nil or trigger.NumAttackerArmies.Minimum == nil)) and {
            Name = "Minimum number of attacking armies";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.NumAttackerArmies = trigger.NumAttackerArmies or {};
                trigger.NumAttackerArmies.Minimum = 5;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MinimumNumberOfAttackingArmiesCondition;
        } or nil;
        ---@cast trigger OnMove
        (trigger.Type == UTIL.TriggerTypes.OnMove and (trigger.NumAttackerArmies == nil or trigger.NumAttackerArmies.Maximum == nil)) and {
            Name = "Maximum number of attacking armies";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.NumAttackerArmies = trigger.NumAttackerArmies or {};
                trigger.NumAttackerArmies.Maximum = 20;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MaximumNumberOfAttackingArmiesCondition;
        } or nil;
        ---@cast trigger OnMove
        (trigger.Type == UTIL.TriggerTypes.OnMove and (trigger.NumAttackerSpecialUnits == nil or trigger.NumAttackerSpecialUnits.Minimum == nil)) and {
            Name = "Minimum number of attacking special units";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.NumAttackerSpecialUnits = trigger.NumAttackerSpecialUnits or {};
                trigger.NumAttackerSpecialUnits.Minimum = 1;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MinimumNumberOfAttackingSpecialUnitsCondition;
        } or nil;
        ---@cast trigger OnMove
        (trigger.Type == UTIL.TriggerTypes.OnMove and (trigger.NumAttackerSpecialUnits == nil or trigger.NumAttackerSpecialUnits.Maximum == nil)) and {
            Name = "Maximum number of attacking special units";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.NumAttackerSpecialUnits = trigger.NumAttackerSpecialUnits or {};
                trigger.NumAttackerSpecialUnits.Maximum = 3;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MaximumNumberOfAttackingSpecialUnitsCondition;
        } or nil;
        ---@cast trigger OnMove
        (trigger.Type == UTIL.TriggerTypes.OnMove and (trigger.AttackersAttackPower == nil or trigger.AttackersAttackPower.Minimum == nil)) and {
            Name = "Minimum of attackers attack power";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.AttackersAttackPower = trigger.AttackersAttackPower or {};
                trigger.AttackersAttackPower.Minimum = 5;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MinimumAttackersAttackPowerCondition;
        } or nil;
        ---@cast trigger OnMove
        (trigger.Type == UTIL.TriggerTypes.OnMove and (trigger.AttackersAttackPower == nil or trigger.AttackersAttackPower.Maximum == nil)) and {
            Name = "Maximum of attackers attack power";
            Action = function()
                saveTrigger(trigger, inputs);
                trigger.AttackersAttackPower = trigger.AttackersAttackPower or {};
                trigger.AttackersAttackPower.Maximum = 20;
                selectFun(trigger);
                close();
            end;
            Info = INFO.MaximumAttackersAttackPowerCondition;
        } or nil;
    };
end

function generateEventValueList(event, selectFun, close)
    local list = {};
    for enum, data in pairs(UTIL.InjectValuesMetaData) do
        list[#list + 1] = valueIsCompatible(event, enum) and {
            Name = data.Name,
            Action = function()
                addValueToEvent(event, enum);
                selectFun(enum);
                close();
            end,
            Info = data.Info,
            Color = data.Color
        } or nil;
    end
    return list;
end

function generateStructuresList(selectFun, blackList)
    blackList = blackList or {};
    local list = {};
    for name, enum in pairs(WL.StructureType) do
        if name ~= "ToString" and not valueInTable(blackList, enum) then
            list[#list + 1] = {
                Name = getReadableString(name),
                Action = function()
                    selectFun(enum);
                end,
                Color = getColorFromList(enum);
            };
        end
    end
    return list;
end

function generateOperatorList(selectFun)
    return {
        {
            Name = "+",
            Action = function()
                selectFun(UTIL.OperatorTypes.Addition);
            end,
            Info = INFO.OperatorAddition
        },
        {
            Name = "-",
            Action = function()
                selectFun(UTIL.OperatorTypes.Minus);
            end,
            Info = INFO.OperatorMinus
        },
        {
            Name = "x",
            Action = function()
                selectFun(UTIL.OperatorTypes.Multiplication);
            end,
            Info = INFO.OperatorMultiplication
        },
        {
            Name = "/",
            Action = function()
                selectFun(UTIL.OperatorTypes.Division);
            end,
            Info = INFO.OperatorDivision
        },
        {
            Name = "%",
            Action = function()
                selectFun(UTIL.OperatorTypes.Modulus);
            end,
            Info = INFO.OperatorModulus
        }
    }
end

function createValueTable(enum)
    return { Type = enum };
end

function createExpression(enum)
    return { 
        Operator = enum,
        Left = {},
        Right = {},
    };
end

function addValueToEvent(event, enum)
    if event.CompatibleTriggerType == 0 then
        event.CompatibleTriggerType = UTIL.InjectValuesConstraints[enum].TriggerType or 0;
    end
end

---Returns the name of the trigger, indexed by the passed type
---@param type TriggerTypeEnum
---@return string
function getTriggerTypeName(type)
    return UTIL.TriggerMetaData[type].Name;
end

---Returns the small info of the trigger, indexed by the passed type
---@param type TriggerTypeEnum
---@return string
function getTriggerTypeInfo(type)
    return UTIL.TriggerMetaData[type].Info;
end

---Returns the color code of the trigger, indexed by the passed type
---@param type TriggerTypeEnum
---@return string
function getTriggerTypeColor(type)
    return UTIL.TriggerMetaData[type].Color;
end

---Returns the number of triggers
---@return number # The number of triggers
function getNumOfTriggers()
    return getTableLength(UTIL.TriggerTypes);
end

---Returns the name of the event type
---@param type EventTypeEnum # The type of event
---@return string # The name of the event
function getEventTypeName(type)
    return UTIL.EventMetaData[type].Name;
end

---Returns the info text of the event type
---@param type EventTypeEnum # The type of the event
---@return string # The info text of the event
function getEventTypeInfo(type)
    return UTIL.EventMetaData[type].Info;
end

---Returns the color of the event type
---@param type EventTypeEnum # The type of the event
---@return string # The color string of the event
function getEventTypeColor(type)
    return UTIL.EventMetaData[type].Color;
end

---Returns the name of the value enum
---@param type ValueEnum
---@return string
function getValueTypeName(type)
    return UTIL.InjectValuesMetaData[type].Name;
end

---Returns the info text of the value enum
---@param type ValueEnum
---@return string
function getValueTypeInfo(type)
    return UTIL.InjectValuesMetaData[type].Info;
end

---Returns the color text of the value enum
---@param type ValueEnum
---@return string
function getValueTypeColor(type)
    return UTIL.InjectValuesMetaData[type].Color;
end

---Returns the number of events
---@return number # The number of events
function getNumOfEvents()
    return getTableLength(UTIL.EventTypes);
end

function getOperatorName(type, rep)
    local t = {
        [UTIL.OperatorTypes.Addition] = "+",
        [UTIL.OperatorTypes.Minus] = "-",
        [UTIL.OperatorTypes.Multiplication] = "x",
        [UTIL.OperatorTypes.Division] = "/",
        [UTIL.OperatorTypes.Modulus] = "%"
    }
    return t[type];
end

function valueIsCompatible(event, enum)
    local t = UTIL.InjectValuesConstraints[enum];
    return (t.EventType == nil or valueInTable(t.EventType, event.Type)) and (t.TriggerType == nil or event.CompatibleTriggerType == 0 or t.TriggerType == event.CompatibleTriggerType);
end

function getSlotIndex(s)
    local c = 0;
    for i = 1, #s do
        local b = string.byte(s, i, i);
        c = c + ((b - 64) * 26^(#s - i));
    end
    c = c - 1;
    -- print(c);
    return c;
end

function validateSlotName(s)
    if #s < 1 then return false; end
    for i = 1, #s do
        local b = string.byte(s, i, i);
        if b > 90 or b < 65 then return false; end
    end
    return true;
end

function getSlotName(slot)
	local s = "";
	slot = slot + 1;
    while slot > 0 do
        local n = slot % 26;
        if n == 0 then
            -- slot % 26 == 26
            n = 26;
        end
        slot = (slot - n) / 26;
        s = string.char(n + 64) .. s;
    end
    return "Slot " .. s;
end

function getColorFromList(n)
    n = n % getTableLength(colors);
    for _, color in pairs(colors) do
        if n == 0 then return color; end
        n = n - 1;
    end
end

---Returns the length of the table
---@param t table<any, any> | nil # The table to count the elements
---@return number # The number of elements in the table, or 0 if passed nil
function getTableLength(t)
    local c = 0;
    for _, _ in pairs(t or {}) do
        c = c + 1;
    end
    return c;
end

function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end

function getReadableString(s)
    local ret = "";
    local A, Z = string.byte("A", 1, 1), string.byte("Z", 1, 1);
    local first = true;
    for i = 1, #s do
        local c = s:byte(i, i);
        if c >= A and c <= Z then
            if not first then
                ret = ret .. " ";
            end
            first = false;
            ret = ret .. string.char(c);
        else
            ret = ret .. string.char(c);
        end
    end
    return ret;
end

function convertTriggerToText(trigger)
    local t = {
        [UTIL.TriggerTypes.OnDeploy] = convertOnDeployTriggerToText,
        [UTIL.TriggerTypes.OnMove] = convertOnMoveTriggerToText,
        [UTIL.TriggerTypes.OnTurnEnd] = convertOnTurnEndTriggerToText,
        [UTIL.TriggerTypes.ManualTrigger] = convertManualTriggerToText,
        [UTIL.TriggerTypes.OnStructureChange] = convertOnStructureChangeTriggerToText
    }
    if t[trigger.Type] == nil then
        return "ERROR: Something went wrong..."
    end
    return t[trigger.Type](trigger);
end

---Converts the given trigger into a readable text, instead of listing all the details
---@param trigger OnDeploy
---@return string
function convertOnDeployTriggerToText(trigger)
    local s = "When";
    if trigger.Slots and #trigger.Slots > 0 then
        if trigger.BlacklistSlots then
            s = s .. " anyone except for" .. convertListToString(trigger.Slots, getSlotName, "and");
        else
            s = s .. convertListToString(trigger.Slots, getSlotName, "or");
        end
    else
        s = s .. " a player";
    end
    return s .. " deploys " .. convertMinMaxToString(trigger.NumDeployed, "armies") .. convertTerritoryDataToString(trigger) .. convertChanceAndCooldownToString(trigger);
end

---Converts the given on move trigger into a readable text, instead of listing all the details 
---@param trigger OnMove
function convertOnMoveTriggerToText(trigger)
    local s = "When";
    if trigger.AttackerSlots and #trigger.AttackerSlots > 0 then
        if trigger.BlacklistAttackerSlots then
            s = s .. " anyone except for" .. convertListToString(trigger.AttackerSlots, getSlotName, "and");
        else
            s = s .. convertListToString(trigger.AttackerSlots, getSlotName, "or");
        end
    else
        s = s .. " a player"
    end
    if trigger.MustBeSuccessful then
        s = s .. " has a successful";
    elseif trigger.MustNotBeSuccessful then
        s = s .. " fails to successfully";
    else
        s = s .. " successfully or fails to";
    end
    if trigger.MustBeAttack then
        s = s .. " attack";
    elseif trigger.MustBeTransfer then
        s = s .. " transfer";
    else
        s = s .. " attack / transfer"
    end
    s = s .. " the territory";
    local list = {};
    local f = function(text)
        if #text > 0 then
            table.insert(list, text);
        end
    end
    f(convertMinMaxToString(trigger.NumAttackerArmies, "armies")); 
    f(convertMinMaxToString(trigger.NumAttackerSpecialUnits, "special units"));
    f(convertMinMaxToString(trigger.AttackersAttackPower, "attack power"));
    local movingArmiesText = convertListToString(list, returnArgument, "and");
    if #movingArmiesText > 0 then
        s = s .. ", with";
    end
    s = s .. movingArmiesText; 
    local terrDataText = convertTerritoryDataToString(trigger, true);
    return s .. terrDataText .. convertChanceAndCooldownToString(trigger);
end

function convertOnTurnEndTriggerToText(trigger)
    local s = "At the end of every turn when";
    if trigger.Slots and #trigger.Slots > 0 then
        if trigger.BlacklistSlots then
            s = s .. " anyone except for" .. convertListToString(trigger.Slots, getSlotName, "and");
        else
            s = s .. convertListToString(trigger.Slots, getSlotName, "or");
        end
    else
        s = s .. " a player";
    end
    return s .. " controls the territory" .. convertTerritoryDataToString(trigger) .. convertChanceAndCooldownToString(trigger);
end

function convertManualTriggerToText(trigger)
    local s = "At the end of every turn when";
    if trigger.Slots and #trigger.Slots > 0 then
        if trigger.BlacklistSlots then
            s = s .. " anyone except for" .. convertListToString(trigger.Slots, getSlotName, "and");
        else
            s = s .. convertListToString(trigger.Slots, getSlotName, "or");
        end
    else
        s = s .. " a player";
    end
    return s .. " controls the territory" .. convertTerritoryDataToString(trigger) .. convertChanceAndCooldownToString(trigger);
end

function convertOnStructureChangeTriggerToText(trigger)
    local s = ""
    return s;
end

---Converts the territory data of the given trigger into a string
---@param trigger Trigger
---@return string
function convertTerritoryDataToString(trigger, includeControllingConditions)
    includeControllingConditions = includeControllingConditions or false;
    local list = {};
    local f = function(text)
        -- print(text);
        if #text > 0 then
            table.insert(list, text);
        end
    end
    f(convertMinMaxToString(trigger.NumArmies, "armies"));
    f(convertMinMaxToString(trigger.NumSpecialUnits, "special units"));
    f(convertMinMaxToString(trigger.DefensePower, "defense power"));
    f(convertMinMaxToString(trigger.AttackPower, "attack power"));
    if includeControllingConditions then
        if trigger.Slots and #trigger.Slots > 0 then
            local andOr = "or"
            local controlledByText = "is controlled by";
            if trigger.BlacklistSlots then
                andOr = "and";
                controlledByText = "is not controlled by"
            end
            f(controlledByText .. convertListToString(trigger.Slots or {}, getSlotName, andOr));
        end
    end
    local s = convertListToString(list, returnArgument, "and");
    if #s > 0 then
        s = ", if the territory has" .. s;
    end
    return s;
end

function convertChanceAndCooldownToString(trigger)
    local s = ", then the trigger will fire its events"
    if trigger.Chance then
        s = s .. " with a " .. round(trigger.Chance, 2) .. "% chance"
        if trigger.Cooldown then
            s = s .. " if not on cooldown. The cooldown is " .. trigger.Cooldown .. " turn" .. appendSIfMultiple(trigger.Cooldown);
        else
            s = s .. "."
        end
    else
        if trigger.Cooldown then
            s = s .. " if not on cooldown. The cooldown is " .. trigger.Cooldown .. " turn" .. appendSIfMultiple(trigger.Cooldown);
        else
            s = s .. "."
        end
    end
    return s;
end

function convertMinMaxToString(data, text)
    local s = "";
    text = text or "";
    if data then
        if data.Minimum and data.Maximum then
            s = s .. "at least " .. data.Minimum .. " and at most " .. data.Maximum .. " " .. text;
        elseif data.Minimum then
            s = s .. "at least " .. data.Minimum .. " " .. text;
        elseif data.Maximum then
            s = s .. "at most " .. data.Maximum .. " " .. text;
        end
    end
    return s;
end

function convertListToString(list, func, andOr)
    andOr = andOr or "and";
    local s = "";
    if #list == 0 then return s; end
    if #list > 2 then
        s = s .. " " .. func(list[1]);
        for i = 2, #list - 1 do
            s = s .. ", " .. func(list[i]);
        end
        s = s .. " " .. andOr .. " " .. func(list[#list]);
    elseif #list == 2 then
        s = s .. " " .. func(list[1]) .. " " .. andOr .. " " .. func(list[2]);
    else
        s = s .. " " .. func(list[1]);
    end
    return s;
end

function appendSIfMultiple(n)
    if n == 1 then return ""; end
    return "s";
end

function round(n, dec)
    local m = 10 ^ dec
    n = n * (m);
    return math.floor(n + 0.5) / m;
end

function returnArgument(a)
    return a;
end

function replaceStructWord(str, new)
    return replaceSubString(str, "{STRUCT}", new);
end

---Returns a string with all occurances of `orig` replaced by `new`
---@param str string # The original string
---@param orig string # The original sub string
---@param new string # The new sub string
---@return string # The string with all `orig` occurances replaced by `new`
function replaceSubString(str, orig, new)
    local res = string.gsub(str, orig, new);
    return res;
end

---Function that does nothing
---@param ... any
function void(...)

end

function getStructureName(enum)
    for name, enum2 in pairs(WL.StructureType) do
        if enum == enum2 then return getReadableString(name); end
    end
    return "None";
end