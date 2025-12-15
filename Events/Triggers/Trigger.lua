---@class Trigger # The parent class of a Trigger
---@field ID TriggerID # The unique identifier of the trigger
---@field Name string # Name of the trigger
---@field Type TriggerTypeEnum # The type of the trigger
---@field IsGlobalTrigger boolean # If true, the trigger will be applied to all territories, otherwise only applies to the territories it has been assigned to
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

---@alias TriggerID integer

Trigger = {
    Info = {
        TriggerName = "This is the name of the trigger. This name is mainly used for you to distinguish this trigger easily between all other created triggers";
        TriggerIsGlobal = "When checked, this trigger will be applied to all the whole map. When not checked, you need to assign this trigger to territories. See the examples for inspiration when to use and when not to use global triggers",
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
        MinimumStructuresOnTerritoryString = "This condition is met when there are at least a certain number of {STRUCT}s structures on the trigger territory. When this is set to 2 {STRUCT}s, this condition is met when there are 2 or more {STRUCT}s on the territory";
        MaximumStructuresOnTerritoryString = "This condition is met when there are at most a certain number of {STRUCT}s structures on the trigger territory. When this is set to 3 {STRUCT}s, this condition is met when there are 3 or less {STRUCT}s on the territory";
    }
};

---Creates a new trigger
---@param triggers table<number, Trigger> # The triggers created so far
---@param type TriggerTypeEnum # The type of the new trigger
---@return Trigger
function Trigger.Create(triggers, type)
    local newID = getHighestID(triggers) + 1;
    ---@type Trigger
    local t = {
        Type = type,
        Name = "New trigger #" .. newID,
        ID = newID,
        IsGlobalTrigger = false
    };
    return t;
end
