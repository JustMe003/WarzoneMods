
function Client_PresentSettingsUI(rootParent)
	local root = UI.CreateVerticalLayoutGroup(rootParent);
	local line;

	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("AI's can play emergency blockade cards: ");
	createBoolLabel(line, Mod.Settings.CanPlayEMB);
	
	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("AI's can play diplomacy cards: ");
	createBoolLabel(line, Mod.Settings.CanPlayDiplomacy);
	
	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("AI's can play sanctions cards: ");
	createBoolLabel(line, Mod.Settings.CanPlaySanctions);
	
	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("AI's can play blockade cards: ");
	createBoolLabel(line, Mod.Settings.CanPlayBlockade);
	
	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	UI.CreateLabel(line).SetText("AI's can play bomb cards: ");
	createBoolLabel(line, Mod.Settings.CanPlayBomb);
end

function createBoolLabel(line, b)
	UI.CreateLabel(line).SetText(getYesOrNo(b)).SetColor(getBoolColor(b));
end

function getYesOrNo(b)
	if b then return "Yes"; end
	return "No";
end

function getBoolColor(b)
	if b then return "#00FF00"; end
	return "#FF0000";
end