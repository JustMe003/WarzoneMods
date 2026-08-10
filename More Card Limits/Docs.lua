---@alias MoreCardLimitsSettings table<CardLimitID, CardSettings>
---@alias MoreCardLimitsInputs table<CardLimitID, CardSettingsInput>

---@alias CardLimitID integer|string

---@class CardSettingsInput
---@field MaxCardHold NumberInputField
---@field MaxGameCardLimit NumberInputField

---@class CardSettings
---@field ID CardLimitID
---@field MaxCardHold integer
---@field MaxGameCardLimit integer
---@field CardType CardTypeEnum

---@enum CardTypeEnum
CardTypeEnum = {
    Base = 1;
    Modded = 2;
}

---Creates and returns a new CardSettings object
---@param id CardLimitID
---@param type CardTypeEnum
---@return CardSettings
function CreateCardSettings(id, type) 
    return {
        ID = id;
        MaxCardHold = 0;
        MaxGameCardLimit = 0;
        CardType = type;
    };
end