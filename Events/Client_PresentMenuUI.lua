require("UI");
require("Util.History");

require("Menus.MainMenu");

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close, refreshed)
    for i, v in pairs(UI) do
        print(i, v, UI2[i]);
        if v ~= UI2[i] then print("Different field: " .. i); end
    end
    GlobalRoot = UI2.CreateVert(rootParent).SetFlexibleWidth(1);
    setMaxSize(500, 600);
    
    if refreshed and Close ~= nil and RefreshFunction ~= nil then
        Close();
        RefreshFunction();
        RefreshFunction = nil;
        Close = close;
        return;
    end
    
    colors = UI2.GetColors();
    Game = game;
    Close = close;
    CancelClickIntercept = true;

    MainMenu.ShowMain();
end