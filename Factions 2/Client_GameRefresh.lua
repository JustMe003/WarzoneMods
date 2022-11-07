function Client_GameRefresh(game)
	if Mod.Settings.VersionNumber == nil or Mod.Settings.VersionNumber == 1 then
		require("Client_GameRefresh1");
	else
		require("Client_GameRefresh2");
	end
	Client_GameRefreshMain(game);
end