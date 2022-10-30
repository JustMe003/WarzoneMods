function Client_SaveConfigureUI(alert)
    Mod.Settings.Cost = costInput.GetValue();
    if Mod.Settings.Cost < 0 then alert("The Medic cost cannot be lower than 0"); end
	Mod.Settings.Percentage = percentageInput.GetValue();
    if Mod.Settings.Percentage > 100 or Mod.Settings.Percentage < 0 then alert("The Medic can only recover a percentage between 0 and 100"); end
    Mod.Settings.Health = healthInput.GetValue();
    if Mod.Settings.Health < 0 then alert("The Medic cannot be less than 0 armies worth"); end
    Mod.Settings.MaxUnits = maxUnitsInput.GetValue();
    if Mod.Settings.MaxUnits < 1 then alert("You cannot allow 0 or less Medics, then you should remove the mod from your game"); end
end