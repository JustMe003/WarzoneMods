function Server_GameCustomMessage(game, playerID, payload, setReturn)
    if Mod.Settings.VersionNumber == nil or Mod.Settings.VersionNumber == 1 then
        require("Server_GameCustomMessage1");
    else
        require("Server_GameCustomMessage2");
    end
    Server_GameCustomMessageMain(game, playerID, payload, setReturn);
end