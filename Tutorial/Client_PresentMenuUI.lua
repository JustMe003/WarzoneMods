require("UI");
require("util");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close, calledFromGameRefresh)
	if not templateIsTutorial(game.Settings.TemplateIDUsed) then close(); UI.Alert("This template is not a tutorial!"); return; end
	Init();
	Colors = GetColors();
	Game = game;
	SetWindow("Main");
	Vert = CreateVert(rootParent);
	Close = function() pageHasClosed = true; close(); end;
	setMaxSize(400, 500);

	if calledFromGameRefresh ~= nil then
		if pageHasClosed ~= nil then
			pageHasClosed = nil;
			require(Mod.PlayerGameData.Tutorial);
			initTutorial();
		else
			close();
		end
	else
		tutorialChoice();
	end
end

function tutorialChoice()
	SetWindow("tutorialChoice");
	CreateLabel(Vert).SetText("Welcome to the Tutorial mod!\nThis mod has tutorials for many public mods. It is meant to show you what game mechanics they add or what tools they offer.").SetColor(Colors["Orange"]);
	CreateLabel(Vert).SetText("\nBefore we start, do you know how this mod works? If not, I recommend taking the small Tutorial tutorial :p").SetColor(Colors["Orange"]);
	local line = CreateHorz(Vert);
	CreateButton(line).SetText("Yes").SetOnClick(function() Close(); Game.SendGameCustomMessage("Updating progress...", {Type="StartedTutorial", Tutorial=Game.Settings.TemplateIDUsed}, function() end); end).SetColor(Colors["Green"]);
	CreateButton(line).SetText("No").SetOnClick(function() Close(); Game.SendGameCustomMessage("Updating progress...", {Type="StartedTutorial", Tutorial="Tutorial"}, function() end); end).SetColor(Colors["Orange Red"]);
end
