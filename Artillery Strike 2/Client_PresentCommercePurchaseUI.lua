require("Annotations");
require("Client_PresentMenuUI");
require("Client_PresentSettingsUI");
require("Util");
require("UI");

---Client_PresentCommercePurchaseUI hook
---@param rootParent RootParent
---@param game GameClientHook
---@param close fun() # Zero parameter function that closes the dialog
function Client_PresentCommercePurchaseUI(rootParent, game, close)
    Init(rootParent);
    local vert = CreateVert(rootParent);
    PurchaseMenuClose = close;
    Game = game;
    colors = GetColors();

    CreateLabel(vert).SetText("Artillery units allow you to order an artillery strike on distant territories, allowing you to deal damage from a distance! To buy an artillery unit click one of the buttons below").SetColor("#DDDDDD")

    CreateEmpty(vert).SetPreferredHeight(10);

    CreateLabel(vert).SetText("The following artillery units are in this game:").SetColor("#DDDDDD");

    for _, art in ipairs(Mod.Settings.Artillery) do
        local numArt = countArtilleryOfType(game.LatestStanding, art.Name, game.Us.ID, true);
        local line = CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
        CreateButton(line).SetText(art.Name).SetColor(art.Color).SetOnClick(function() 
            buyArtillery(art);
        end).SetInteractable(art.CanBeBought and numArt < art.MaxNumOfArtillery);
        if art.CanBeBought then
            CreateEmpty(line).SetFlexibleWidth(1);
            CreateLabel(line).SetText(numArt .. " / " .. art.MaxNumOfArtillery).SetColor("#DDDDDD");
        else
            CreateLabel(line).SetText("This artillery cannot be bought");
        end
        CreateButton(line).SetText("?").SetColor("#23A0FF").SetOnClick(function()
            game.CreateDialog(function(rootPar, size, scroll, game, closeSettings)
                root  = UI.CreateVerticalLayoutGroup(rootPar).SetFlexibleWidth(1);
                size(400, 400);
                showArtillerySettings(art, true, function() closeSettings(); end);
            end)
        end);
    end
end

function buyArtillery(art)
    PurchaseMenuClose();
    Game.CreateDialog(function(a, b, c, d, e) Client_PresentMenuUI(a, b, c, d, e, art) end);
end
