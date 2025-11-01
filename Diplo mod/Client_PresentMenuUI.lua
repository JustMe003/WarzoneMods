require("UI");
require("utilities");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close, calledFromGameRefresh)
	Init();
	colors = GetColors();

	local vert = CreateVert(rootParent).SetCenter(true).SetFlexibleWidth(1);
	GlobalRoot = CreateVert(vert).SetCenter(true).SetFlexibleWidth(1);
	
	local line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Version: ");
	if Mod.Settings.VersionNumber == nil or Mod.Settings.VersionNumber == 1 then
		require("Client_PresentMenuUI1");
		CreateLabel(line).SetText(MOD_VERSION_1).SetColor(colors.TextColor);
	else
		require("Client_PresentMenuUI2");
		CreateLabel(line).SetText(MOD_VERSION_2).SetColor(colors.TextColor);
	end
	Client_PresentMenuUIMain(vert, setMaxSize, setScrollable, Game, close, calledFromGameRefresh);
end