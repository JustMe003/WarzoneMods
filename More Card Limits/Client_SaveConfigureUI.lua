require("Util");

function Client_SaveConfigureUI(alert, _)
    SaveInputs();

    local alerts = ValidateSettings();
    if #alerts > 0 then
        alert(string.format("[%s]: There are some issues with the current settings, please resolve them all: \n\n%s", MOD_NAME, table.concat(alerts, "\n")));
    end
end

function SaveInputs()
    local alerts = {};
    if inputs ~= nil then
        for id, input in pairs(inputs) do
            data[id].MaxCardHold = input.MaxCardHold.GetValue();
            data[id].MaxGameCardLimit = input.MaxGameCardLimit.GetValue();
        end
    end

    inputs = nil;
    return alerts;
end

function ValidateSettings()
    local alerts = {};
    for id, settings in pairs(data) do
        if settings.MaxCardHold > settings.MaxGameCardLimit then
            table.insert(alerts, string.format("The hand limit of the card '%s' is more than its full game limit", GetCardName(id)));
        end
    end
    return alerts
end