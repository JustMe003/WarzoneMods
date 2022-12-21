function Client_PresentConfigureUI(rootParent)
	local includeInGamePlayers = Mod.Settings.IncludeInGamePlayers
    if includeInGamePlayers == nil then includeInGamePlayers = true; end

    local line = UI.CreateHorizontalLayoutGroup(rootParent);
    includeInGamePlayersInput = UI.CreateCheckbox(line).SetIsChecked(includeInGamePlayers).SetText(" ");
    UI.CreateLabel(line).SetText("Include players who got booted, eliminated or surrendered").SetColor("#DDDDDD");
end