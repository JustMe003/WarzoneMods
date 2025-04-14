function Client_SaveConfigureUIMain(alert)
	saveSettings();
	Mod.Settings.GlobalSettings = settings;
	Mod.Settings.Configuration = config;
	Mod.Settings.VersionNumber = 1;
end
