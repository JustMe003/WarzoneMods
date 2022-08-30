require("UI");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, Game, close)
	init(rootParent);
	game = Game;
	
	showMenu();
end

function showMenu()
	local win = "showMenu";
	if windowExists(win) then
		resetWindow(win);
	end
	destoyWindow(getCurrentWindow());
	window(win)
	local vert = newVerticalGroup("vert", "root");
	
	for i = 0, 49 do
		getPlayerSlot(i);
	end
end

function getPlayerSlot(n)
	for _, p in pairs(game.Game.Players) do
		if p.Slot == n then 
			print(p.Slot, p.State);
			p.DisplayName(nil, false); 
		end
	end
end