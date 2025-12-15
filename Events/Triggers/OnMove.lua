require("Triggers.Trigger");

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

OnMove = {
    Info = {
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
    }
};