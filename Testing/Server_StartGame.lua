function Server_StartGame(game, standing)
  for i, v in pairs(game.ServerGame.ActiveTerritoryPicks) do
    for k, v2 in pairs(v) do
      print(i, k, v2);
    end
  end
end
