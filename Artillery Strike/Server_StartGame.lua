require("DistributeStructures");
function Server_StartGame(game, standing)
	local data = Mod.PublicGameData;
	data.TotalArtilleryShots = {};
	for i, _ in pairs(game.ServerGame.Game.PlayingPlayers) do
		data.TotalArtilleryShots[i] = 0;
	end
	Mod.PublicGameData = data;
	if Mod.Settings.CustomScenario then return; end
	if game.Settings.AutomaticTerritoryDistribution == false then return; end
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