require("Annotations");
require("UI");

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)
	Init();
    local textColor = GetColors().TextColor;

    local root = CreateVert(rootParent).SetFlexibleWidth(1);
    
    local line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Number of pieces to divide the card into").SetColor(textColor);
    numPieces = CreateNumberInputField(line).SetSliderMinValue(1).SetSliderMaxValue(20).SetValue(Mod.Settings.NumPieces or 10);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Minimum pieces awarded per turn").SetColor(textColor);
    piecesPerTurn = CreateNumberInputField(line).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(Mod.Settings.PiecesPerTurn or 1);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Pieces given to each player at the start").SetColor(textColor);
    startingPieces = CreateNumberInputField(line).SetSliderMinValue(0).SetSliderMaxValue(10).SetValue(Mod.Settings.StartingPieces or 0);
    
    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateLabel(line).SetText("Number of turns the card will last").SetColor(textColor);
    duration = CreateNumberInputField(line).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(Mod.Settings.Duration or 3);
    
    CreateEmpty(root).SetPreferredWidth(5);

    line = CreateHorz(root).SetFlexibleWidth(1);
    CreateEmpty(line).SetFlexibleWidth(1);
    CreateLabel(line).SetText("AI can play Forced LD cards").SetColor(textColor);
    AIAutoplayCards = CreateCheckBox(line).SetText(" ").SetIsChecked(Mod.Settings.AIAutoplayCards or false);
    CreateEmpty(line).SetFlexibleWidth(1);
end