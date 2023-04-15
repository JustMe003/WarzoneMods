function Client_GameRefresh(game)
  print("Testing");
  for i, v in pairs(game.Orders) do
    print(i, v.proxyType)
  end
end
