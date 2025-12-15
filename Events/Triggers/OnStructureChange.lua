require("Triggers.Trigger");

---@class OnStructureChange : Trigger # Trigger for modifications to structures
---@field StructureChanges table<integer, MinMaxObject>? # The minimum and maximum change to fire this trigger

OnStructureChange = {
    Info = {
        MinimumStructuresChangeString = "This condition allows you to trigger events when a certain amount of {STRUCT}s structures are added or removed from the territory.\n\nFor example, when set to -2, the condition is met when there are 2 or more {STRUCT}s REMOVED from the territory.\n\nWhen set to 2, the condition is met when there are 2 or more {STRUCT}s ADDED to the territory";
        MaximumStructuresChangeString = "This condition allows you to trigger events when a certain amount of {STRUCT}s structures are added or removed from the territory.\n\nFor example, when set to -2, the condition is met when there are 2 or less {STRUCT}s REMOVED from the territory.\n\nWhen set to 2, the condition is met when there are 2 or less {STRUCT}s ADDED to the territory";
    }
}
