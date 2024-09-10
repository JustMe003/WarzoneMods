require("Annotations");
require("UI");

---Client_PresentSettingsUI hook
---@param rootParent RootParent
function Client_PresentSettingsUI(rootParent)
	Init();
    local colors = GetColors();

    local root = CreateVert(rootParent).SetFlexibleWidth(1);

    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Number of pieces the card is divided into:").SetColor(colors.TextColor);
        CreateEmpty(line).SetPreferredWidth(10);
        CreateLabel(line).SetText(Mod.Settings.NumPieces).SetColor(colors.Aqua);
    end, "The number of pieces you need to obtain a card");
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Number of pieces awarded each turn").SetColor(colors.TextColor);
        CreateEmpty(line).SetPreferredWidth(10);
        CreateLabel(line).SetText(Mod.Settings.PiecesPerTurn).SetColor(colors.Aqua);
    end, "The number of pieces a player gets awarded if they successfully capture a territory");
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Pieces given at the start").SetColor(colors.TextColor);
        CreateEmpty(line).SetPreferredWidth(10);
        CreateLabel(line).SetText(Mod.Settings.StartingPieces).SetColor(colors.Aqua);
    end, "The number of pieces each player starts the game with");
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Duration of the card").SetColor(colors.TextColor);
        CreateEmpty(line).SetPreferredWidth(10);
        CreateLabel(line).SetText(Mod.Settings.Duration).SetColor(colors.Aqua);
    end, "The number of turns the card will last when played");
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("AI can play this card").SetColor(colors.TextColor);
        CreateEmpty(line).SetPreferredWidth(10);
        if Mod.Settings.AIAutoplayCards then
            CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        else
            CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
        end
    end, "When true, this option allows AI players (or teams that consist of only AI) to play Forced LD cards. They will play the cards as soon as possible on a random target, but not at their teammates. \n\nDoes nothing if the option is not selected");
    CreateInfoButtonLine(root, function(line)
        CreateLabel(line).SetText("Can play Forced LD card on teammates").SetColor(colors.TextColor);
        CreateEmpty(line).SetPreferredWidth(10);
        if Mod.Settings.CanPlayOnTeammates then
            CreateLabel(line).SetText("Yes").SetColor(colors.Green);
        else
            CreateLabel(line).SetText("No").SetColor(colors["Orange Red"]);
        end
    end, "When true, players can play Forced LD cards on teammates. When false, this is not permitted by the mod");
end