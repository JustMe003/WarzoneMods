function Client_GameOrderCreated(game, order, skipOrder)
    print("UI table: " .. tostring(UI));
    for i, v in pairs(UI) do
        print(i, v);
    end
    UI.Alert("This is annoying isn't it?");
end