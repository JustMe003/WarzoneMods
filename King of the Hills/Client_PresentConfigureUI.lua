require("UI");

---Client_PresentConfigureUI hook
---@param rootParent RootParent
function Client_PresentConfigureUI(rootParent)
	Init();
    local textColor = GetColors().TextColor;

    local root = CreateVert(rootParent);
    CreateLabel(root).SetText("Select the number of hills").SetColor(textColor);
    numHills = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(Mod.Settings.NumHills or 3);

    CreateEmpty(root).SetPreferredHeight(5);

    CreateLabel(root).SetText("The number of turns a hill must be occupied in succession to win the game").SetColor(textColor);
    numTurns = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(Mod.Settings.NumTurns or 1);

    CreateLabel(root).SetText("The number of armies on a hill at the start of the game").SetColor(textColor);
    numArmies = CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(20).SetValue(Mod.Settings.NumArmies or 10);
end