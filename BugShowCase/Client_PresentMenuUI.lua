function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if not UI.IsDestroyed(vert) and Close ~= nil then       -- UI.IsDestroyed(vert) is always true
        Close();
    end

    vert = UI.CreateVerticalLayoutGroup(rootParent);
    Close = close;          -- We use this to close off the previous window
end