require("DataConverter")
function Client_SaveConfigureUI(alert)
    Mod.Settings.Cost = costInput.GetValue();
    if Mod.Settings.Cost < 0 then alert("The Medic cost cannot be lower than 0"); end
	Mod.Settings.Percentage = percentageInput.GetValue();
    if Mod.Settings.Percentage > 100 or Mod.Settings.Percentage < 0 then alert("The Medic can only recover a percentage between 0 and 100"); end
    Mod.Settings.Health = healthInput.GetValue();
    if Mod.Settings.Health < 0 then alert("The Medic cannot be less than 0 armies worth"); end
    Mod.Settings.MaxUnits = maxUnitsInput.GetValue();
    if Mod.Settings.MaxUnits < 1 then alert("You cannot allow 0 or less Medics, then you should remove the mod from your game"); end
    DataConverter.SetKey();
    Mod.Settings.UnitDescription = DataConverter.DataToString({Data = {Unit = "\\\\\\"}, Essentials = {UnitDescription = "{{Data/Unit}} {{AttackPower}} {{DefensePower}} {{Player}}  The medic does not like standing on the front lines, but rather wants to stay back to heal up any wounded soldiers. Any time the player owning this unit loses armies on a territory connected to this medic, it will recover " .. Mod.Settings.Percentage .. "% of the armies lost\n\nThis unit can be bought for " .. Mod.Settings.Cost .. " gold in the purchase menu (same place where you buy cities)\n\nEach player can have up to " .. Mod.Settings.MaxUnits .. " Medic(s), so you can't have an army of Medics unfortunately"}});
    print(Mod.Settings.UnitDescription);
end