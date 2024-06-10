require("Annotations");
require("UI");

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    Init(rootParent);
    root = GetRoot();
    colors = GetColors();
    Game = game;

    showMain();
end

function showMain()
    DestroyWindow()
    SetWindow("Main");

    CreateLabel(root).SetText("turn " .. Game.Game.TurnNumber - 1).SetColor(colors.TextColor);
    CreateTextInputField(root).SetText(Mod.PublicGameData.SerializedTurn).SetPreferredWidth(2000);
end
