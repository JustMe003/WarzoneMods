require("DistributeStructures");

function Server_StartGame(game, standing)
	
	if game.Settings.AutomaticTerritoryDistribution then
		standing = distributeStructure(game, standing, Mod.Settings.numberOfHospitals, WL.StructureType.Hospital)
	end
	
	local data = Mod.PublicGameData;
	
	if Mod.Settings.maximumHospitalRange > 1 then
		local increment = (Mod.Settings.recoverPercentageMaximum - Mod.Settings.recoverPercentageMinimum) / (Mod.Settings.maximumHospitalRange - 1);
		local values = {};
		for i = 0, Mod.Settings.maximumHospitalRange - 1 do
			values[i + 1] = Mod.Settings.recoverPercentageMaximum - (i * increment);
		end
		data.Values = values;
	else
		data.Values = {Mod.Settings.recoverPercentageMinimum};
	end
	Mod.PublicGameData = data;
end