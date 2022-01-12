function Client_SaveConfigureUI(alert)
	Mod.Settings.distributionTerritories = distributionTerritoriesOnly.GetIsChecked();
	Mod.Settings.additionalTerritories = math.max(territoryCount.GetValue(),1);
	Mod.Settings.takeTurnsPicking = splitDistribution.GetIsChecked();
	Mod.Settings.numberOfGroups = math.min(math.max(groupPlayers.GetValue(),1),40);
	
	if Mod.Settings.takeTurnsPicking == nil or Mod.Settings.takeTurnsPicking == false then
		Mod.Settings.numberOfGroups = 1;
	end
	
end