-- code
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
    game = Game;
    Game.GetTurn(Game.Game.TurnNumber - 2, callback);
end

function callback(t)
    for i, v in pairs (game.Orders) do
        print(i, v.OccursInPhase);
    end
    for i, v in pairs(t.Orders) do
        if v.proxyType == "GameOrderEvent" then
            print(v.ModID);
        end
    end
end
