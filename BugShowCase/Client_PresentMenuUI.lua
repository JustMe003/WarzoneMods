require("UI");

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close, refreshed)
    local root = UI2.CreateVert(rootParent);

    for i, v in pairs(Mod.PublicGameData.Players or {}) do
        print(i, v);
    end

    local textInput = UI2.CreateTextInputField(root).SetPlaceholderText("PlayerID").SetCharacterLimit(20).SetPreferredWidth(200);

    UI2.CreateButton(root).SetText("Submit").SetColor("#0000FF").SetOnClick(function()
        local num = tonumber(textInput.GetText());
        if type(num) ~= "number" then UI2.Alert("Please enter a valid ID"); return; end
        game.SendGameCustomMessage("Adding your ID", {ID = num}, function() UI2.Alert("Succes!"); close(); end);
    end);
end