require("Client_PresentMenuUI");
function Client_GameRefresh(game)
	if (stage == nil and isOpen == nil) or stage ~= Mod.PlayerGameData.Progress and game.Settings.SinglePlayer then
		game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, true); end);
	end
	stage = Mod.PlayerGameData.Progress;
	isOpen = true;
end