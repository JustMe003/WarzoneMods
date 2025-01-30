	
function Client_PresentConfigureUI(rootParent)
	CanPlayEMB = Mod.Settings.CanPlayEMB;
	if(CanPlayEMB == nil)then CanPlayEMB = false; end
	CanPlayDiplomacy = Mod.Settings.CanPlayDiplomacy;
	if(CanPlayDiplomacy == nil)then CanPlayDiplomacy = false; end
	CanPlaySanctions = Mod.Settings.CanPlaySanctions;
	if(CanPlaySanctions == nil)then CanPlaySanctions = false; end
	CanPlayBlockade = Mod.Settings.CanPlayBlockade;
	if(CanPlayBlockade == nil)then CanPlayBlockade = false; end
	CanPlayBomb = Mod.Settings.CanPlayBomb;
	if(CanPlayBomb == nil)then CanPlayBomb = false; end

	local root = UI.CreateVerticalLayoutGroup(rootParent);
	local line;
	
	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	UI.CreateEmpty(line).SetFlexibleWidth(0.5);
	UI.CreateLabel(line).SetText("AI's can play ...");
	UI.CreateEmpty(line).SetFlexibleWidth(0.5);
	
	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	CanPlayEMBCheckBox = UI.CreateCheckBox(line).SetText("Emergency Blockade cards").SetIsChecked(CanPlayEMB);
	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	CanPlayDiplomacyCheckBox = UI.CreateCheckBox(line).SetText("Diplomacy cards").SetIsChecked(CanPlayDiplomacy);
	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	CanPlaySanctionsCheckBox = UI.CreateCheckBox(line).SetText("Sanction cards").SetIsChecked(CanPlaySanctions);
	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	CanPlayBlockadeCheckBox = UI.CreateCheckBox(line).SetText("Blockade cards").SetIsChecked(CanPlayBlockade);
	line = UI.CreateHorizontalLayoutGroup(root).SetFlexibleWidth(1);
	CanPlayBombCheckBox = UI.CreateCheckBox(line).SetText("Bomb cards").SetIsChecked(CanPlayBomb);
end
