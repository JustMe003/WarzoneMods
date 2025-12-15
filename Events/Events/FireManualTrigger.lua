require("Events.Event");

---@class FireManualTrigger : Event # Tries to fire a ManualTrigger trigger
---@field NotifyNeighbours boolean # When checked, will try to notify all neighbours of the event territory
---@field TerritoryID integer # Then ID of the territory with the trigger
---@field TriggerID TriggerID # The ID of the ManualTrigger

FireManualTriggerEvent = {};

FireManualTriggerEvent.Info = {
    EventNotifyNeighbours = "When checked, the selected trigger on all neighbouring territories will be notified, regardless whether they are selected or not. If a neighbouring territory does not have the selected trigger, nothing will happen",
    EventSelectManualTrigger = "You must select which trigger will be notified by this event, alongside the territory. This is necessary since a territory can have multiple manual triggers",
    EventSelectTerritory = "You must select a territory, that in turn has a manual trigger. Together with the linked manual trigger, the mod will know which trigger to notify. This is needed, since a territory can have multiple manual triggers assigned to it",
}