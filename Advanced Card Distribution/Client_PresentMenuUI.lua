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
	destroyWindow(getCurrentWindow());
	window(win)
	local vert = newVerticalGroup("vert", "root");
	
	print("All players:");
	for _, p in pairs(game.Game.Players) do
		print(p.DisplayName(nil, false));
	end
	print("\n")
	
	for i = 0, 49 do
		getPlayerSlot(i);
	end
end

function getPlayerSlot(n)
	for _, p in pairs(game.Game.Players) do
		if p.Slot == n then 
			print(p.DisplayName(nil, false), p.Slot, p.State);
			p.DisplayName(nil, false); 
		end
	end
end