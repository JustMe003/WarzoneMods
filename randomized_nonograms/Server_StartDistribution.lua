function Server_StartDistribution(game, standing)
	if Mod.Settings.CustomDistribution == true and Mod.PublicGameData.IsValid then
		local s = standing;
		local map = Mod.PublicGameData.Map;
		local size = Mod.PublicGameData.Size;
		local i = 1;
		while i <= size do
			local j = 1;
			while j <= size do
				if map[i][j] == 1 then
					s.Territories[(i - 1) * size + j].OwnerPlayerID = WL.PlayerID.AvailableForPicking;
				else
					s.Territories[(i - 1) * size + j].OwnerPlayerID = WL.PlayerID.Neutral;
				end
				j = j + 1;
			end
			i = i + 1;
		end
	end
end