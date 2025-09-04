require("Client_PresentMenuUI")

---Client_GameRefresh hook
---@param game GameClientHook
function Client_GameRefresh(game)
	if GlobalRoot ~= nil and not UI.IsDestroyed(GlobalRoot) then
        showMain();
    end
end