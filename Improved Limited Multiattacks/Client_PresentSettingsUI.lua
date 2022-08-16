
function Client_PresentSettingsUI(rootParent)
	local horz = UI.CreateHorizontalLayoutGroup(rootParent);
	if(Mod.Settings.MaxAttacks ~= 0)then
		UI.CreateLabel(horz).SetText(Mod.Settings.MaxAttacks .. ' transfer range');
		UI.CreateButton(horz).SetText('?').SetColor('#00B5FF').SetOnClick(function() UI.Alert('This setting tells you, what the attack range of the multiattack is. Please note, that you are able to enter orders further then the range, but those will not be executed'); end);
	end
end