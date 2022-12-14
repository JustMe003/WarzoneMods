function Server_AdvanceTurn_Start(game, addNewOrder)
	local data = Mod.PublicGameData;
    if data.NonPlayingPlayers == nil then data.NonPlayingPlayers = {}; end
    for _, p in pairs(game.Game.Players) do
        if playerIsOut(p.State) and not valueInTable(data.NonPlayingPlayers, p.ID) then
            for p2, _ in pairs(game.Game.PlayingPlayers) do
                local instance = WL.NoParameterCardInstance.Create(WL.CardID.Spy);
                addNewOrder(WL.GameOrderReceiveCard.Create(p.ID, {instance}));
                addNewOrder(WL.GameOrderPlayCardSpy.Create(instance.ID, p.ID, p2));
            end
            local instance = WL.NoParameterCardInstance.Create(WL.CardID.Spy);
            addNewOrder(WL.GameOrderReceiveCard.Create(p.ID, {instance}));
            addNewOrder(WL.GameOrderPlayCardSpy.Create(instance.ID, p.ID, WL.PlayerID.Neutral));
            table.insert(data.NonPlayingPlayers, p.ID);
        end
    end
    Mod.PublicGameData = data;
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	
end

function Server_AdvanceTurn_End(game, addNewOrder)
	
end

function playerIsOut(state)
    return state == WL.GamePlayerState.Eliminated or state == WL.GamePlayerState.Booted or state == WL.GamePlayerState.SurrenderAccepted;
end

function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end