local funcs = require("test");

---Client_PresentMenuUI hook
---@param rootParent RootParent
---@param setMaxSize fun(width: integer, height: integer)
---@param setScrollable fun(hor: boolean, vert: boolean)
---@param game GameClientHook
---@param close fun()
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    print(funcs);
end