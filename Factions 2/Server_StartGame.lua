if Mod.Settings.VersionNumber == nil or Mod.Settings.VersionNumber == 1 then
    require("Server_StartGame1");
else 
    require("Server_StartGame2");
end