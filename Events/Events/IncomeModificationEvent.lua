require("Events.Event");

require("Enums.InjectValueEnums");

---@class IncomeModificationEvent : Event # Event that adds an income modification for a player
---@field Player ValueTable # The player receiving the income modification
---@field IncomeMod ValueTable | Expression # The amount of income added or removed
---@field Duration number # The number of turns this income modification will last
--- Local deployment?

IncomeModificationEvent = {};

IncomeModificationEvent.Info = {
    EventIncomeModDuration = "The amount of turns this income modification will last. When set to 5 for example, once the event has happened, the player will receive additional income for 5 turn from then. The value 0 indicates that the income modification will last until the end of the game. If the event happens again when the income modification is still in play, it will be stacked.",
}