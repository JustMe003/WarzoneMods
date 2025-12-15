require("Events.Event");

---@class AddStructuresEvent : Event # Event that changes the number of structures on the territory
---@field Addition table<integer, Expression | ValueTable> # The number of structures to be added or removed

AddStructuresEvent = {};

AddStructuresEvent.Info = {
    EventStructureModification = "Here you can configure how many structures of what type are added/removed. Note that a structure count can be set to negative. You can create an expression for each structure individually.",
}