require("Annotations");
require("UI");

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number) # Sets the max size of the dialog
---@param setScrollable fun(horizontallyScrollable: boolean, verticallyScrollable: boolean) # Set whether the dialog is scrollable both horizontal and vertically
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    for i = 0, game.Game.TurnNumber - 1 do
		for j = 0, game.Game.TurnNumber - 2 do
			game.GetStanding(i, j, function(t) 
				print("i: " .. i, "j: " .. j, t.Territories[1].NumArmies.NumArmies);
			end);
		end
		print();
	end 
end