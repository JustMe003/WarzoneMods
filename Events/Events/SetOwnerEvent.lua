require("Events.Event");

require("Enums.InjectValueEnums");

---@class SetOwnerEvent : Event # Event that changes the owner of the territory
---@field NewPlayer ValueEnum # The slot that will become the new owner