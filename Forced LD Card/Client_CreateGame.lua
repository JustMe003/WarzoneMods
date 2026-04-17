require("VersionNumber");

local customCardVersion = VersionNumber.CreateVersionNumberString(1, 1);

function Client_CreateGame(settings, alert)
    if not VersionNumber.VersionIsEqualOrHigher(customCardVersion, Mod.Settings.Version) then
        alert("The mod has been updated! Please revisit the mod settings page to update the settings of the mod");
    end
end