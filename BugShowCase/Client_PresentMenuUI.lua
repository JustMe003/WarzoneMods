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

    local orders = Game.Orders;
    for i = 3, 100, 5 do
        addOrder(orders, WL.GameOrderCustom.Create(game.Us.ID, "Occurs in phase: " .. i, "", {}, i));
    end
    for _, order in pairs(orders) do
        print(order.OccursInPhase);
    end
    Game.Orders = orders;

end

function addOrder(orders, order)
    local index = 0;
    for i, o in pairs(orders) do
        if o.OccursInPhase ~= nil and o.OccursInPhase > order.OccursInPhase then
            print(o.OccursInPhase, order.OccursInPhase);
            index = i;
            break;
        end
    end
    if index == 0 then index = #orders; end
    table.insert(orders, index, order);
end