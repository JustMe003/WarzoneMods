require("UI");
require("util");
function Client_PresentConfigureUI(rootParent)
	Init(rootParent);
	local colors = GetColors();
	local root = GetRoot();
	autoDistributeUnits = Mod.Settings.AutoDistributeUnits;
	if autoDistributeUnits == nil then autoDistributeUnits = false; end
	nUnitsIsNTerrs = Mod.Settings.NUnitsIsNTerrs;
	if nUnitsIsNTerrs == nil then nUnitsIsNTerrs = true; end
	numberOfUnits = Mod.Settings.NumberOfUnits;
	if numberOfUnits == nil then numberOfUnits = 3; end
	includeCommanders = Mod.Settings.IncludeCommanders;
	if includeCommanders == nil then includeCommanders = true; end
	canBeAirliftedToSelf = Mod.Settings.CanBeAirliftedToSelf
	if canBeAirliftedToSelf == nil then canBeAirliftedToSelf = false; end
	teamsCountAsOnePlayer = Mod.Settings.TeamsCountAsOnePlayer
	if teamsCountAsOnePlayer == nil then teamsCountAsOnePlayer = false; end

	local line = CreateHorz(root).SetFlexibleWidth(1);
	autoDistributeUnitsInput = CreateCheckBox(line).SetText(" ").SetIsChecked(autoDistributeUnits);
	CreateLabel(line).SetText("Auto distribute the link units").SetColor(colors.Tan);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When enabled, the mod will automatically (but efficiently) distribute the link units for players. When this option is disabled and players do not deploy all their link units, the mod will auto distribute the remaining units for them regardless of this setting"); end);
	line = CreateHorz(root).SetFlexibleWidth(1);
	local vert = CreateVert(root);
	nUnitsIsNTerrsInput = CreateCheckBox(line).SetText(" ").SetIsChecked(nUnitsIsNTerrs).SetOnValueChanged(function() if nUnitsIsNTerrsInput.GetIsChecked() then numberOfUnits = numberOfUnitsInput.GetValue(); DestroyWindow("Extrainput"); else inputNumberUnits(vert); end; end);
	CreateLabel(line).SetText("Give players the same amount of link units as they have territories").SetColor(colors.Tan);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When enabled, the mod will allow the same amount of link units to be placed as players have territories. The maximum unit count with this option enabled is 5. When disabled, it will allow you to enter any number bigger than 0"); end);
	if not nUnitsIsNTerrs then
		inputNumberUnits(vert);
	end
	line = CreateHorz(root).SetFlexibleWidth(1);
	includeCommandersInput = CreateCheckBox(line).SetText(" ").SetIsChecked(includeCommanders);
	CreateLabel(line).SetText("Commanders also act like link units").SetColor(colors.Tan);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("[Recommended]\nWhen enabled, commanders also function as a link unit. This is to prevent players losing their commanders to neutral territories, where other players can eliminated them without them being able to defend it"); end);
	line = CreateHorz(root).SetFlexibleWidth(1);
	canBeAirliftedToSelfInput = CreateCheckBox(line).SetText(" ").SetIsChecked(canBeAirliftedToSelf);
	CreateLabel(line).SetText("Players can airlift link units").SetColor(colors.Tan);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When enabled, the link units can be airlifted to the player themselves. Airlifting to teammembers requires the 'Teams count as 1 player' setting to be enabled"); end);
	line = CreateHorz(root).SetFlexibleWidth(1);
	teamsCountAsOnePlayerInput = CreateCheckBox(line).SetText(" ").SetIsChecked(teamsCountAsOnePlayer);
	CreateLabel(line).SetText("Teams count as 1 player").SetColor(colors.Tan);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When enabled, the mod will process teammembers as one player. This setting will only do something if the game is a team game"); end);
	
end

function inputNumberUnits(root)
	SetWindow("Extrainput");
	CreateLabel(root).SetText("The number of link units each player (can) get").SetColor(colors.Tan);
	numberOfUnitsInput = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(numberOfUnits);
end