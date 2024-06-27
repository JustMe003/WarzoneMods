require("Annotations");
require("DataConverter");

---Client_SaveConfigureUI hook
---@param alert fun(message: string) # Alert the player that something is wrong, for example, when a setting is not configured correctly. When invoked, cancels the player from saving and returning
function Client_SaveConfigureUI(alert)
	if currentArtillery ~= nil then
        saveArtillery(artilleryList[currentArtillery], artilleryInputs);
    end
    Mod.Settings.Artillery = artilleryList;
    if artilleryPlacementsInputs ~= nil then
        savePlacement();
    end
    DataConverter.SetKey(Mod);
    Mod.Settings.ArtilleryPlacements = placements
end