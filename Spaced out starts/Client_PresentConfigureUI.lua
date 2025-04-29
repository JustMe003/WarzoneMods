function Client_PresentConfigureUI(rootParent)
    local root = UI.CreateVerticalLayoutGroup(rootParent);
    
    UI.CreateLabel(root).SetText("The minimum amount of territories between each starting territory").SetColor("#DDDDDD");
    minSpacesApart = UI.CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(Mod.Settings.SpaceBetweenStarts or 2);

    UI.CreateEmpty(root).SetPreferredHeight(5);
    UI.CreateLabel(root).SetText("Note that this mod tries to place every start in a configuration where they are at least the required number of territories apart from eachother, but might not succeed for every starting territory. Things that improve the odds that the mod can place every start correctly are the map size, the number of players and the distance between starting territories. Be sure to test out your settings in a few singleplayer games first!").SetColor("#DDDDDD");
end