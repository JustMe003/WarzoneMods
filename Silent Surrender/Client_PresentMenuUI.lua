function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	if Mod.PublicGameData.Prints == nil then return; end
	for _, v in pairs(Mod.PublicGameData.Prints) do
		UI.CreateLabel(vert).SetText(tostring(v));
	end
end