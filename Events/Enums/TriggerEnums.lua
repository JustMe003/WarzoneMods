TriggerTypeEnum = {
    ON_DEPLOY = 1,
    ON_MOVE = 2,
    ON_TURN_END = 3,
    MANUAL_TRIGGER = 4,
    ON_STRUCTURE_CHANGE = 5
};

local TriggerTypeMetaData = {
    [TriggerTypeEnum.ON_DEPLOY] = {
        Color = "#0000FF", 
        Name = "Deployment trigger", 
        Info = "This trigger will only be notified when a player deploys on the territory the trigger is assigned to";
    },
    [TriggerTypeEnum.ON_MOVE] = {
        Color = "#59009D", 
        Name = "Attack/transfer trigger", 
        Info = "This trigger will only be notified when a player transfers or attacks the territory the trigger is assigned to";
    },
    [TriggerTypeEnum.ON_TURN_END] = {
        Color = "#009B9D", 
        Name = "Turn end trigger", 
        Info = "This trigger will always be notified when at the end of every turn";
    },
    [TriggerTypeEnum.MANUAL_TRIGGER] = {
        Color = "#AC0059",
        Name = "Manual trigger", 
        Info = "This trigger can only be notified by a event";
    },
    [TriggerTypeEnum.ON_STRUCTURE_CHANGE] = {
        Color = "#B70AFF",
        Name = "Structures change trigger", 
        Info = "This trigger will only be notified when the territory it is assigned to gets a change in its structures";
    }
}

---Returns the name of the trigger, indexed by the passed type
---@param type TriggerTypeEnum
---@return string
function TriggerTypeEnum.GetTriggerTypeName(type)
    return TriggerTypeMetaData[type].Name;
end

---Returns the small info of the trigger, indexed by the passed type
---@param type TriggerTypeEnum
---@return string
function TriggerTypeEnum.GetTriggerTypeInfo(type)
    return TriggerTypeMetaData[type].Info;
end

---Returns the color code of the trigger, indexed by the passed type
---@param type TriggerTypeEnum
---@return string
function TriggerTypeEnum.GetTriggerTypeColor(type)
    return TriggerTypeMetaData[type].Color;
end
