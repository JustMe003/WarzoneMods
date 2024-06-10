require("Annotations");
require("DataConverter");


---Client_SaveConfigureUI hook
---@param alert fun(message: string) # Alert the player that something is wrong, for example, when a setting is not configured correctly. When invoked, cancels the player from saving and returning
function Client_SaveConfigureUI(alert)
    if #dataInput.GetText() > 0 then
        Mod.Settings.Data = copyTable(DataConverter.StringToData(dataInput.GetText()));
    end
end


function copyTable(t)
    local ret = {};
    for i, v in pairs(t) do
        if type(v) == "table" then
            ret[i] = copyTable(v);
        else
            ret[i] = v;
        end
    end
    return ret;
end