function Client_GameRefresh(game)
	if game.Us == nil then return; end
	if not game.Us.HumanTurnedIntoAI then
		for i, v in pairs(WL.GamePlayerState) do
			print(i, v);
		end
	end
end