	
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

	horzlist = {};
	horzlist[0] = UI.CreateHorizontalLayoutGroup(rootParent);
	UI.CreateLabel(horzlist[0]).SetText("AI's can play ...");
	horzlist[2] = UI.CreateHorizontalLayoutGroup(rootParent);
	CanPlayEMBCheckBox = UI.CreateCheckBox(horzlist[2]).SetText("Emergency Blockade cards").SetIsChecked(CanPlayEMB);
	horzlist[3] = UI.CreateHorizontalLayoutGroup(rootParent);
	CanPlayDiplomacyCheckBox = UI.CreateCheckBox(horzlist[3]).SetText("Diplomacy cards").SetIsChecked(CanPlayDiplomacy);
	horzlist[4] = UI.CreateHorizontalLayoutGroup(rootParent);
	CanPlaySanctionsCheckBox = UI.CreateCheckBox(horzlist[4]).SetText("Sanction cards").SetIsChecked(CanPlaySanctions);
	horzlist[5] = UI.CreateHorizontalLayoutGroup(rootParent);
	CanPlayBlockadeCheckBox = UI.CreateCheckBox(horzlist[5]).SetText("Blockade cards").SetIsChecked(CanPlayBlockade);
	horzlist[6] = UI.CreateHorizontalLayoutGroup(rootParent);
	CanPlayBombCheckBox = UI.CreateCheckBox(horzlist[6]).SetText("Bomb cards").SetIsChecked(CanPlayBomb);

end
