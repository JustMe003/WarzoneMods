if Mod.Settings.VersionNumber == nil or Mod.Settings.VersionNumber == 1 then
    require("Server_AdvanceTurn1");
else
    require("Server_AdvanceTurn2");
end