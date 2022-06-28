require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if game.Game.TurnNumber < 1 then return; end
	init(rootParent);
	destroyWindow(getCurrentWindow());
	
	local teamGame;
	for _, player in pairs(game.Game.PlayingPlayers) do
		teamGame = not (player.Team == -1);
		break;
	end

	local win = "main";
	if windowExists(win) then
		restoreWindow(win);
	else
		window(win);
		local vert = newVerticalGroup("vert", "root");
		newLabel(win .. "desc", vert, "Number of flags still standing before the team getting eliminated", "Royal Blue");
		for i, v in pairs(Mod.PublicGameData.FlagsLost) do
			if teamGame then
				newLabel(win .. i, vert, getTeamName(i) .. ": " .. math.min(Mod.Settings.NFlagsForLose - v, getTableLength(Mod.PublicGameData.Flags[i])), "Light Blue");
			else
				newLabel(win .. i, vert, game.Game.Players[i].DisplayName(nil, false) .. ": " .. math.min(Mod.Settings.NFlagsForLose - v, getTableLength(Mod.PublicGameData.Flags[i])), game.Game.Players[i].Color.HtmlColor);	
			end
		end
	end
end


function getTeamName(n)
	local list = {"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"}
	local ret = "";
	if n > #list then
		ret = ret .. list[math.floor(n/#list)];
	end
	ret = ret .. list[n % #list + 1];
	return ret;
end


function getTableLength(t)
	local c = 0;
	for i, _ in pairs(t) do
		c = c + 1;
	end
	return c;
end
