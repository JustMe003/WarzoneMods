---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: integer, height: integer)
---@param setScrollable fun(hor: boolean, vert: boolean)
---@param game GameClientHook
---@param close fun()
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    print(2, game.LatestStanding.NumResources(game.Us.ID, 2));
    print(5, game.LatestStanding.NumResources(game.Us.ID, 5));

	close();
end