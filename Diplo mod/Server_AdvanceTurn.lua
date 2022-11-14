function Server_AdvanceTurn_Start(game, addNewOrder)
    if Mod.Settings.VersionNumber == nil or Mod.Settings.VersionNumber == 1 then
        require("Server_AdvanceTurn1");
    else
        require("Server_AdvanceTurn2");
    end
    Server_AdvanceTurn_StartMain(game, addNewOrder);
end