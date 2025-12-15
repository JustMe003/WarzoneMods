---@class Event # The parent class for an event
---@field Name string # Name of the event
---@field Type EventTypeEnum # The event type
---@field ID EventID # The ID of the event
---@field CompatibleTriggerType `0` | TriggerTypeEnum # If set, the event can use data that fired the trigger. If not, the event can be used by any trigger but cannot use any trigger data specifically

Event = {};

Event.Info = {
    EventName = "This is the name of the event. This name is mainly used for you to distinguish an event easily between all other events",
}

---Creates a new event
---@param events table<number, Event> # The events created so far
---@param type any
---@return Event
function Event.Create(events, type)
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