require("Util");
---comment
---@param game any
---@param skipCommit any
function Client_GameCommit(game, skipCommit)
    local reloadingArtilleries = getReloadingArtilleries(game.LatestStanding.Territories, game.Orders);
    for _, order in pairs(game.Orders) do
        local s = isInvalidAttackTransferOrder(game, order);
        if s ~= nil then
            UI.Alert(s .. ". Attack/transfer order from " .. game.Map.Territories[order.From].Name .. " to " .. game.Map.Territories[order.To].Name);
            skipCommit();
        end
    end
end