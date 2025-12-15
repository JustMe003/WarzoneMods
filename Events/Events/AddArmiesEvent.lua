require("Events.Event");

---@class AddArmiesEvent : Event # Event that changes the number of armies on the territory
---@field Expression ValueTable | Expression # The number of armies added or subtracted
AddArmiesEvent = {}

AddArmiesEvent.Info = {
    EventAddArmies = "Here you can create your own expression to determine how many armies will be added/removed from the event territory. This can be a simple number like 10, or you can make it so that 10% of the current armies are added to the territory. Note that the expression is calculated from TOP to BOTTOM, with priority given to expressions in brackets '()'",
}