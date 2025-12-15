EventTypeEnum = {
    MESSAGE_EVENT = 1,
    SET_OWNER_EVENT = 2,
    ADD_ARMIES_EVENT = 3,
    ADD_STRUCTURES_EVENT = 4,
    INCOME_MODIFICATION_EVENT = 5,
    FIRE_MANUAL_TRIGGER = 6,
}

local EventTypeMetaData = {
    [EventTypeEnum.MESSAGE_EVENT] = {
        Color = "#C04000",
        Name = "Message event",
        Info = "This event will add an order only displaying a message. This message can be send to everyone, or to certain players only. It is always visible for everyone who can see the territory";
    },
    [EventTypeEnum.SET_OWNER_EVENT] = {
        Color = "#94652E",
        Name = "Set owner event",
        Info = "This event will set the owner of the territory to a specific player. The player can be a pre-determined slot, or a player that contributed in firing the trigger (and thus this event)";
    },
    [EventTypeEnum.ADD_ARMIES_EVENT] = {
        Color = "#AD7E7E",
        Name = "Modify armies event",
        Info = "This event will allow you to add the armies on the event territory";
    },
    [EventTypeEnum.ADD_STRUCTURES_EVENT] = {
        Color = "#8EBE57",
        Name = "Modify structures event",
        Info = "This event will allow you to add to the event territory";
    },
    [EventTypeEnum.INCOME_MODIFICATION_EVENT] = {
        Color = "#FFAF56",
        Name = "Income modification event",
        Info = "This event will add an income modification for a player. This player can be an pre-determined slot or a player that contributed in firing the trigger (and thus this event)";
    },
    [EventTypeEnum.FIRE_MANUAL_TRIGGER] = {
        Color = "#4169E1",
        Name = "Fire manual trigger",
        Info = "This event will notify a manual trigger. This event is meant to create custom events on different a different territory. See the examples for to see what use cases this event has";
    }
}

---Returns the name of the event type
---@param type EventTypeEnum # The type of event
---@return string # The name of the event
function EventTypeEnum.GetEventTypeName(type)
    return EventTypeMetaData[type].Name;
end

---Returns the info text of the event type
---@param type EventTypeEnum # The type of the event
---@return string # The info text of the event
function EventTypeEnum.GetEventTypeInfo(type)
    return EventTypeMetaData[type].Info;
end

---Returns the color of the event type
---@param type EventTypeEnum # The type of the event
---@return string # The color string of the event
function EventTypeEnum.GetEventTypeColor(type)
    return EventTypeMetaData[type].Color;
end