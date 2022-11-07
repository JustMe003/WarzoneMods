function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close, calledFromGameRefresh)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	local line = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(line).SetText("Mod Author: ").SetColor("#DDDDDD");
	UI.CreateLabel(line).SetText("Just_A_Dutchman_").SetColor("#8EBE57");
	line = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(line).SetText("Version: ").SetColor("#DDDDDD");
	if Mod.Settings.VersionNumber == nil or Mod.Settings.VersionNumber == 1 then
		require("Client_PresentMenuUI1");
		UI.CreateLabel(line).SetText("1.5").SetColor("#FF4700");
	else
		require("Client_PresentMenuUI2");
		UI.CreateLabel(line).SetText("2.3").SetColor("#FF4700");
	end
	UI.CreateEmpty(vert).SetPreferredHeight(10);
	Client_PresentMenuUIMain(vert, setMaxSize, setScrollable, Game, close, calledFromGameRefresh);
end