require("DistributeStructures");

function Server_StartDistribution(game, standing)
	if Mod.Settings.CustomScenario then return; end
	if Mod.Settings.Cannons and Mod.Settings.Mortars then
		local t = {};
		t[WL.StructureType.Mortar] = Mod.Settings.AmountOfMortars;
		t[WL.StructureType.Attack] = Mod.Settings.AmountOfCannons;
		distributeStructuresOnePerTerr(game, standing, t);
	elseif Mod.Settings.Mortars then
		distributeStructure(game, standing, Mod.Settings.AmountOfMortars, WL.StructureType.Mortar);
	elseif Mod.Settings.Cannons then
		distributeStructure(game, standing, Mod.Settings.AmountOfCannons, WL.StructureType.Attack);
	end
end