require("UI");
require("utilities")

function Client_PresentSettingsUI(rootParent)
	Init();
	colors = GetColors();
	local vert = CreateVert(rootParent).SetCenter(true).SetFlexibleWidth(1);
	GlobalRoot = CreateVert(vert).SetCenter(true).SetFlexibleWidth(1);
	
	local line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Version: ");
	if Mod.Settings.VersionNumber == nil or Mod.Settings.VersionNumber == 1 then
		require("Client_PresentSettingsUI1");
		CreateLabel(line).SetText(MOD_VERSION_1).SetColor(colors.TextColor);
	else
		require("Client_PresentSettingsUI2");
		CreateLabel(line).SetText(MOD_VERSION_2).SetColor(colors.TextColor);
	end

    Client_PresentSettingsUIMain();
end