require("UI")
local colors = init();
local vert;
local game;

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, ClientGame, close)
--	setMaxSize(500, 500);
	game = ClientGame;
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	permanentLabel = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(permanentLabel).SetText("Mod creator:\t").SetColor(colors.TextColor);
	UI.CreateLabel(permanentLabel).SetText("Just_A_Dutchman_").SetColor(getColor(1311724, game.Game.Players, colors.Lime));
	showMenu();
end

function showMenu()
	resetAll();
	createButton(vert, "settings", "#3333FF", showSettings);
	createButton(vert, "Credits", "#88FF00", showCredits);
	if game.Game.Players[1311724] ~= nil then
		createButton(vert, "show player ID's", colors.Aqua, showPlayerIDs);
	end
end

function showPlayerIDs()
	resetAll()
	for ID, player in pairs(game.Game.Players) do
		line = getNewHorz(vert)
		createLabel(line, ID .. "\t" .. player.DisplayName(nil, false), colors.TextColor)
	end
end

function showCredits()
	resetAll();
	line = getNewHorz(vert);
	createLabel(line, "testers:", colors.TextColor);
	line = getNewHorz(vert);
--	createLabel(line, "Priamus \t", getColor(3629785970, game.Game.Players, colors.SaddleBrown));
--	createLabel(line, "krinid \t", getColor(79105823914, game.Game.Players, colors.TyrianPurple));
--	createLabel(line, "ShatteredMagpie \t", getColor(13126682508, game.Game.Players, colors.Orchid));
--	line = getNewHorz(vert);
--	createLabel(line, "[GW] Rob \t", getColor(72115235360, game.Game.Players, colors.Blue));
--	createLabel(line, "unFairerOrb76 \t", getColor(67130550347, game.Game.Players, colors.Yellow));
--	createLabel(line, "DooDlefight \t", getColor(39131934059, game.Game.Players, colors.DarkGreen));
--	line = getNewHorz(vert);
--	createLabel(line, "καλλιστηι \t", getColor(51131559866, game.Game.Players, colors.Red));
--	createLabel(line, "JK_3 \t", getColor(31105111944, game.Game.Players, colors.Green));
--	createLabel(line, "Samek \n", getColor(69135440841, game.Game.Players, colors.Ivory));
	createButton(vert, "close", "#33CC33", showMenu);

end

function showSettings()
	resetAll();
	if Mod.Settings.CustomDistribution == true then
		createLabel(getNewHorz(), "Custom distribution is being used", "#33CC33");
		createLabel(getNewHorz(), "This option enforces manual distribution, and all pickable territories are in bonuses",colors.TextColors);
	else
		createLabel(getNewHorz(), "Custom distribution is not being used", "#BB3333");
	end
	createLabel(getNewHorz(), "The dimensions of the nonogram are:",colors.TextColors);
	line = getNewHorz(vert);
	createLabel(line, Mod.Settings.NonogramWidth, "#3333FF");
	createLabel(line, " by ",colors.TextColors);
	createLabel(line, " " .. Mod.Settings.NonogramHeigth, "#3333FF");
	createLabel(getNewHorz(), "The density is set to:",colors.TextColors);
	createLabel(getNewHorz(), Mod.Settings.NonogramDensity, "#33FFFF");
	if Mod.Settings.NonogramDensity >= 60 then
		createLabel(getNewHorz(), "This means the nonogram is likely solveable, there should be 1 answer possible", "#33CC33");
	else
		createLabel(getNewHorz(), "This means the nonogram might not be solveable, you might get stuck because there is more than 1 answer possible", "#CC3333");
	end
	if Mod.Settings.LocalDeployments == true then
		createLabel(getNewHorz(), "Custom local deployments is on, this means that all armies you get from territories are automatically deployed, 1 on each territory in the bonus", "#33CC33");
	else
		createLabel(getNewHorz(), "Custom local deployments is off, if commerce is on you'll get gold to spend on armies",colors.TextColors);
	end
	createButton(vert, "close", "#33CC33", showMenu);
end
