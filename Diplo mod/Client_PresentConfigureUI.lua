require("UI");
require("utilities");

function Client_PresentConfigureUI(rootParent)
	Init();
	colors = GetColors();
	GlobalRoot = CreateVert(rootParent).SetFlexibleWidth(1).SetCenter(true);

	checkVersion();
end

function showChoices()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot).SetCenter(true));

	local versionDescriptionLabel;
	CreateLabel(root).SetText("Select which version of the mod you want to use for your game").SetColor(colors.TextColor);
	local radioGroup = CreateRadioButtonGroup(root);

	local line = CreateHorz(root);
	local firstVersion = CreateRadioButton(line).SetGroup(radioGroup).SetText(" ").SetIsChecked(false).SetOnValueChanged(function()
		versionDescriptionLabel.SetText("A player can only be in 1 Faction at a time");
	end);
	CreateLabel(line).SetText("Version " .. MOD_VERSION_1).SetColor(colors.TextColor);

	line = CreateHorz(root);
	local secondVersion = CreateRadioButton(line).SetGroup(radioGroup).SetText(" ").SetIsChecked(true).SetOnValueChanged(function()
		versionDescriptionLabel.SetText("A player can be in multiple Factions at a time");
	end);
	CreateLabel(line).SetText("Version " .. MOD_VERSION_2).SetColor(colors.TextColor);

	versionDescriptionLabel = CreateLabel(root).SetText("A player can be in multiple Factions at a time").SetColor(colors.TextColor);

	line = CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
	CreateButton(line).SetText("Select").SetColor(colors.Green).SetOnClick(function()
		if firstVersion.GetIsChecked() then Mod.Settings.VersionNumber = 1; 
		elseif secondVersion.GetIsChecked() then Mod.Settings.VersionNumber = 2; end
		checkVersion();
	end);
	CreateButton(line).SetText("Rules").SetColor(colors.Yellow).SetOnClick(function()
		showRules(showChoices);
	end);
end

function checkVersion()
	if Mod.Settings.VersionNumber ~= nil then
		Version = Mod.Settings.VersionNumber;
		if Mod.Settings.VersionNumber == 1 then
			require("Client_PresentConfigureUI1");
		else
			require("Client_PresentConfigureUI2");
		end
		Client_PresentConfigureUIMain();
	elseif Mod.Settings ~= nil and not tableIsEmpty(Mod.Settings) then
		Version = 1;
		require("Client_PresentConfigureUI1");
		Client_PresentConfigureUIMain();
	else
		showChoices();
	end
end
