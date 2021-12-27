require("UI")
require("GiveIncome")
local colors;
local vert;
local game;

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, ClientGame, close)
--	setMaxSize(500, 500);
	game = ClientGame;
	colors = initColors();
	players = game.Game.Players;
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	permanentLabel = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(permanentLabel).SetText("Mod creator:\t").SetColor(colors.TextColor);
	UI.CreateLabel(permanentLabel).SetText("Just_A_Dutchman_").SetColor(getColor("Just_A_Dutchman_", players, colors.Lime));
	showMenu();
end

function showMenu()
	init()
	createButton(vert, "Income per player", colors.Orange, showIncome);
	createButton(vert, "Settings", colors.Blue, showSettings);
	createButton(vert, "Credits", colors.Lime, showCredits);
end

function getAllPlayers() 
	local array = {};
	for ID,_ in pairs(game.Game.PlayingPlayers) do 
		array[ID] = 0;
	end
	return array;
end;

function showIncome()
	destroyAll();
	local players = getAllPlayers();
	if game.Game.TurnNumber > 0 then
		for bonusID, listOfTerr in pairs(Mod.PublicGameData.Bonuses) do
			local owner = 0;
			for _, terrID in pairs(listOfTerr) do
				terr = game.LatestStanding.Territories[terrID];
				if terr.FogLevel < 4 then
					if terr.OwnerPlayerID ~= WL.PlayerID.Neutral and owner == 0 then
						owner = terr.OwnerPlayerID;
					elseif terr.OwnerPlayerID == WL.PlayerID.Neutral or owner ~= terr.OwnerPlayerID then
						owner = 0;
						break;
					end
				else 
					owner = 0;
					break; 
				end
			end
			if owner ~= 0 then
				players[owner] = players[owner] + #listOfTerr;
			end
		end
		createLabel(vert, "as far as the fog allows you to see this are the income value per player", colors.TextColor);
		for ID, income in pairs(players) do
			line = getNewHorz(vert);
			createLabel(line, game.Game.Players[ID].DisplayName(nil, false), game.Game.Players[ID].Color.HtmlColor);
			createLabel(line, " will get  ", colors.TextColor);
			createLabel(line, income, game.Game.Players[ID].Color.HtmlColor);
			createLabel(line, " gold", colors.TextColor);
		end
	else
		createLabel(vert, "This option is not available in the distribution stage", colors.ErrorColor);
	end
end

function showCredits()
	destroyAll();
	line = getNewHorz(vert);
	createLabel(line, "testers:", colors.TextColor);
	line = getNewHorz(vert);
	createLabel(line, "Priamus \t", getColor("Priamus", players, colors.SaddleBrown));
	createLabel(line, "krinid \t", getColor("krinid", players, colors.TyrianPurple));
	createLabel(line, "ShatteredMagpie \t", getColor("ShatteredMagpie", players, colors.Orchid));
	line = getNewHorz(vert);
	createLabel(line, "[GW] Rob \t", getColor("[GW] Rob", players, colors.Blue));
	createLabel(line, "unFairerOrb76 \t", getColor("unFairerOrb76", players, colors.Yellow));
	createLabel(line, "DooDlefight \t", getColor("DooDlefight", players, colors.DarkGreen));
	line = getNewHorz(vert);
	createLabel(line, "καλλιστηι \t", getColor("καλλιστηι", players, colors.Red));
	createLabel(line, "JK_3 \t", getColor("JK_3", players, colors.Green));
	createLabel(line, "Samek \n", getColor("Samek", players, colors.Ivory));
	createButton(vert, "close", "#33CC33", function() destroyAll(); showMenu(); end);

end

function showSettings()
	destroyAll();
	if Mod.Settings.CustomDistribution == true then
		createLabel(getNewHorz(vert), "Custom distribution is being used", colors.TrueColor);
		createLabel(getNewHorz(vert), "This option enforces manual distribution, and all pickable territories are in bonuses",colors.TextColor);
	else
		createLabel(getNewHorz(vert), "Custom distribution is not being used", colors.FalseColor);
	end
	createLabel(getNewHorz(vert), "The dimensions of the nonogram are:", colors.TextColor);
	line = getNewHorz(vert);
	createLabel(line, Mod.Settings.NonogramWidth, colors.NumberColor);
	createLabel(line, " by ",colors.TextColor);
	createLabel(line, Mod.Settings.NonogramHeigth, colors.NumberColor);
	createLabel(getNewHorz(vert), "The density is set to:", colors.TextColor);
	createLabel(getNewHorz(vert), Mod.Settings.NonogramDensity, colors.NumberColor);
	if Mod.Settings.NonogramDensity >= 60 then
		createLabel(getNewHorz(vert), "This means the nonogram is likely solveable, there should be 1 answer possible", colors.TextColor);
	else
		createLabel(getNewHorz(vert), "This means the nonogram might not be solveable, you might get stuck because there is more than 1 answer possible", colors.WarningNumberColor);
	end
	if Mod.Settings.LocalDeployments == true then
		createLabel(getNewHorz(vert), "Custom local deployments is on, this means that all armies you get from territories are automatically deployed, 1 on each territory in the bonus", colors.TextColor);
	else
		createLabel(getNewHorz(vert), "Custom local deployments is off, if commerce is on you'll get gold to spend on armies",colors.TextColor);
	end
	createButton(vert, "close", "#33CC33", function() destroyAll(); showMenu(); end);
end
