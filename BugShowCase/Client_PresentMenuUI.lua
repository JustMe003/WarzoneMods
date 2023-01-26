function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    print(UI.IsDestroyed(vert))
	if not UI.IsDestroyed(vert) and Close ~= nil then       -- UI.IsDestroyed(vert) is always true
        print(UI.IsDestroyed(vert))
        Close();
    end

    vert = UI.CreateVerticalLayoutGroup(rootParent);
    Close = close;          -- We use this to close off the previous window

    UI.CreateButton(vert).SetText("Close me").SetOnClick(function() Close() end)
end