function Client_SaveConfigureUI(alert)
    if Version == nil then
        alert("You must pick a mod version for the Factions mod!");
        return;
    end
    if Version == 1 then
        require("Client_SaveConfigureUI1");
    else
        require("Client_SaveConfigureUI2");
    end
    Client_SaveConfigureUIMain(alert);
end