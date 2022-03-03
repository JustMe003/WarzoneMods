function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	local vert = UI.CreateVerticalLayoutGroup(rootParent);
	for _, v in pairs(Mod.PublicGameData.Prints) do
		UI.CreateLabel(vert).SetText(tostring(v));
	end
end