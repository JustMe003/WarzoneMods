require("Events.Event");

require("Enums.InjectValueEnums");

---@class MessageEvent : Event # Event that sends a message to players
---@field Message SubMessage[] # The text to be send
---@field Receivers integer[] # The slots that will receive the message
---@field BroadcastMessage boolean? # If true, everyone will receive the message. Otherwise only the slots in Receivers will

---@alias SubMessage string | ValueEnum

MessageEvent = {};

MessageEvent.Info = {
    EventBroadcastMessage = "When checked, everybody will see this message. When not checked, only the players with vision on the event territory and those manually included will see the message",
    EventMessageReceivers = "Additional players (slots) that will always receive the message. Does nothing if the broadcast setting is checked",
    EventMessage = "Piece your own custom message together. The text inputs are fixed, in the sense that everything put there will by shown exactly as you put it. The values are the way to \"inject\" any game data in the message. They will be replaced by their respective value when the message is shown";
}