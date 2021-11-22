local clientGame;
local vert;
local buttons;
local labels;
local horz;
local textColor = "#AAAAAA";

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, ClientGame, close)
--	setMaxSize(500, 500);
	clientGame = ClientGame;
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	buttons = {};
	labels = {};
	horz = {};
	permanentLabel = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(permanentLabel).SetText("Mod creator:\t").SetColor(textColor);
	UI.CreateLabel(permanentLabel).SetText("Just_A_Dutchman_").SetColor("#88DD00");
	showMenu();
end

function showMenu()
	resetAll();
	createButton(vert, "settings", "#3333FF", showSettings);
	createButton(vert, "Credits", "#88FF00", showCredits);
end

function giveMoreIncome()
	payload = {};
	payload.Message = "giveGold"
	payload.PlayerID = clientGame.Us.ID;
	payload.Amount = Mod.PublicGameData.FTI[clientGame.Us.ID]
	clientGame.SendGameCustomMessage("giving gold...", payload, function()end);
	showMenu();
end

function showCredits()
	resetAll();
	line = getNewHorz();
	createNewLabel(line, "testers:", textColor);
	line = getNewHorz();
	createNewLabel(line, "Priamus \t", "#8b4513");
	createNewLabel(line, "krinid \t", "#77023C");
	createNewLabel(line, "ShatteredMagpie \t", "#FFC0CB");
	line = getNewHorz();
	createNewLabel(line, "[GW] Rob \t", "#0000FF");
	createNewLabel(line, "unFairerOrb76 \t", "#F7CA18");
	createNewLabel(line, "DooDlefight \t", "#014420");
	line = getNewHorz();
	createNewLabel(line, "καλλιστηι \t", "#ff0000");
	createNewLabel(line, "JK_3 \t", "#50EE50");
	createNewLabel(line, "Samek \n", "#FFFEEE");
	createButton(vert, "close", "#33CC33", showMenu);

end

function showSettings()
	resetAll();
	if Mod.Settings.CustomDistribution == true then
		createNewLabel(getNewHorz(), "Custom distribution is being used", "#33CC33");
		createNewLabel(getNewHorz(), "This option enforces manual distribution, and all pickable territories are in bonuses", textColor);
	else
		createNewLabel(getNewHorz(), "Custom distribution is not being used", "#BB3333");
	end
	createNewLabel(getNewHorz(), "The dimensions of the nonogram are:", textColor);
	line = getNewHorz();
	createNewLabel(line, Mod.Settings.NonogramWidth, "#3333FF");
	createNewLabel(line, " by ", textColor);
	createNewLabel(line, " " .. Mod.Settings.NonogramHeigth, "#3333FF");
	createNewLabel(getNewHorz(), "The density is set to:", textColor);
	createNewLabel(getNewHorz(), Mod.Settings.NonogramDensity, "#33FFFF");
	if Mod.Settings.NonogramDensity >= 60 then
		createNewLabel(getNewHorz(), "This means the nonogram is likely solveable, there should be 1 answer possible", "#33CC33");
	else
		createNewLabel(getNewHorz(), "This means the nonogram might not be solveable, you might get stuck because there is more than 1 answer possible", "#CC3333");
	end
	if Mod.Settings.LocalDeployments == true then
		createNewLabel(getNewHorz(), "Custom local deployments is on, this means that all armies you get from territories are automatically deployed, 1 on each territory in the bonus", "#33CC33");
	else
		createNewLabel(getNewHorz(), "Custom local deployments is off, if commerce is on you'll get gold to spend on armies", textColor);
	end
	createButton(vert, "close", "#33CC33", showMenu);
end

function getNewHorz()
	table.insert(horz, UI.CreateHorizontalLayoutGroup(vert));
	return horz[#horz];
end

function createNewLabel(line, text, color)
	table.insert(labels, UI.CreateLabel(line).SetText(text).SetColor(color));
end

function createButton(root, text, color, func)
	table.insert(buttons, UI.CreateButton(root).SetText(text).SetColor(color).SetOnClick(func));
end

function resetAll()
	deleteUI(buttons);
	deleteUI(labels);
	deleteUI(horz);
	horz = {};
	buttons = {};
	labels = {};
end

function deleteUI(list)
	for ID, item in pairs(list) do
		UI.Destroy(item);
	end
end