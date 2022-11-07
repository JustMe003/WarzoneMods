function Client_SaveConfigureUIMain(alert)
	local globalSettings = {};
	globalSettings.VisibleHistory = getIsChecked(VisibleHistory);
	globalSettings.AICanDeclareOnPlayer = getIsChecked(AICanDeclareOnPlayer);
	globalSettings.AICanDeclareOnAI = getIsChecked(AICanDeclareOnAI);
	globalSettings.FairFactions = getIsChecked(FairFactions);
	globalSettings.ApproveFactionJoins = getIsChecked(ApproveFactionJoins);
	globalSettings.LockPreSetFactions = getIsChecked(LockPreSetFactions);
	globalSettings.PlaySpyOnFactionMembers = getIsChecked(PlaySpyOnFactionMembers);
	if objectsID[FairFactionsModifier] ~= nil then
		globalSettings.FairFactionsModifier = math.min(math.max(getValue(FairFactionsModifier), 0), 1);
	else
		globalSettings.FairFactionsModifier = 0.5;
	end
	Mod.Settings.GlobalSettings = globalSettings;
	Mod.Settings.Configuration = config;
	Mod.Settings.VersionNumber = 2;
end