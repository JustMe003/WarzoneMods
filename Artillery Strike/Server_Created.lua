require("Utilities");

function Server_Created(game, settings)
	local data = Mod.PublicGameData;
	if Mod.Settings.Cannons then
		data.DamageCannons = {};
		local inc = (Mod.Settings.MaxCannonDamage - Mod.Settings.MinCannonDamage) / (Mod.Settings.RangeOfCannons - 1);
		for i = 1, Mod.Settings.RangeOfCannons do
			data.DamageCannons[i] = Mod.Settings.MaxCannonDamage - inc * (i - 1);
		end
	end
	if Mod.Settings.Mortars then
		data.MissPercentages = {};
		local inc = (Mod.Settings.MaxMissPercentage - Mod.Settings.MinMissPercentage) / (Mod.Settings.RangeOfMortars - 1);
		for i = 1, Mod.Settings.RangeOfMortars do
			data.MissPercentages[i] = Mod.Settings.MinMissPercentage + inc * (i - 1);
		end
	end
	Mod.PublicGameData = data;
end