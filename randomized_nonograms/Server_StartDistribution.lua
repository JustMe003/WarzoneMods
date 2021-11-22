require("setDistribution");

function Server_StartDistribution(game, standing)
	if Mod.Settings.CustomDistribution == true then
		setDistribution(game, standing, Mod.PublicGameData.Bonuses);
	end
end
