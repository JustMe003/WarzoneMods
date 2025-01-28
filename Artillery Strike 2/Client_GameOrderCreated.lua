require("Util");
require("DataConverter");

---Client hook for order creation
---@param game GameClientHook
---@param order GameOrder
---@param skipOrder fun()
function Client_GameOrderCreated(game, order, skipOrder)
    local s = isInvalidAttackTransferOrder(game, order);
    if s ~= nil then
        UI.Alert(s);
        skipOrder();
    end
end
