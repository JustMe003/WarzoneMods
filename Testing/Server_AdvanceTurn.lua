function Server_AdvanceTurn_Start(game, addNewOrder)
	local d = Mod.PublicGameData;
    d.PendingStateTransitions = game.ServerGame.PendingStateTransitions;
    Mod.PublicGameData = d;
end

function Server_AdvanceTurn_Order(game, order, orderResult, skipThisOrder, addNewOrder)
	
end

function Server_AdvanceTurn_End(game, addNewOrder)
	
end