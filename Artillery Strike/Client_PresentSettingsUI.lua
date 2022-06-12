require("UI");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	local win = "main";
	if windowExists(win) then
		destroyWindow(getCurrentWindow());
		restoreWindow(win);
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup(win .. "vert", "root");
		newLabel("amountOfStructuresNote", vert, "Note that the number of cannons and mortars actually in the game might be less than configured", "Red");
		newLabel("ArtilleryShot", vert, "Players can shoot an artillery strike every " .. Mod.Settings.ArtilleryShot .. " times", "Orange");
		newLabel("UseGold", vert, "Players can buy artillery strikes with gold: " .. tostring(Mod.Settings.UseGold), "Yellow");
		if Mod.Settings.UseGold then
			newLabel("GoldCost", vert, "An artillery strike costs " .. Mod.Settings.GoldCost .. " gold", "Orange");
		end
		newLabel("CustomScenario", vert, "The mod did not place any cannons and / or mortars: " .. tostring(Mod.Settings.CustomScenario));
		newLabel("cannons", vert, "Cannons:", "Lime");
		if Mod.Settings.Cannons then
			newLabel("usesCannons", vert, "This game uses cannons", "Cyan");
			newLabel("nCannons", vert, "The mod was configured to place " .. Mod.Settings.AmountOfCannons .. " cannons randomly around the map", "Light Blue");
			newLabel("maxDamageCannons", vert, "Cannons deal " .. Mod.Settings.MaxCannonDamage .. "% damage to directly connected territories", "Cyan");
			newLabel("minDamageCannons", vert, "Cannons deal " .. Mod.Settings.MinCannonDamage .. "% damage to territories at their maximum range", "Light Blue");
			newLabel("cannonDamageExplanation", vert, "The damage for each territory in range of a cannon decreases with the distance between the cannon and target increases. If the maximum damage is greater than the minimum damage cannons can deal more damage to closeby territories than those further away", "Cyan");
			newLabel("rangeOfCannons", vert, "Cannons are configured to have a range of " .. Mod.Settings.RangeOfCannons, "Light Blue");
		else
			newLabel("noCannons", vert, "This game does not use cannons", "Orange Red");
		end
		newLabel("mortars", vert, "Mortars:", "Lime");
		if Mod.Settings.Mortars then
			newLabel("usesMortars", vert, "This game uses mortars", "Cyan");
			newLabel("nMortars", vert, "The mod was configured to place " .. Mod.Settings.AmountOfMortars .. " mortars randomly around the map", "Light Blue");
			newLabel("damageMortars", vert, "Mortars deal a constant " .. Mod.Settings.MortarDamage .. "% damage to territories in range", "Cyan");
			newLabel("missExplanation", vert, "Although mortars deal a constant percentage damage to territories this does not mean they always hit their target territory with the same percentage. Where cannons deal less damage the bigger the distance between the cannon and target, mortars have a bigger chance to hit a territory directly connected to the target territory the bigger the distance between the mortar and target territory. More about this can be found in the Essentials mod", "Light Blue");
			newLabel("minMissPercentage", vert, "Mortars have a " .. Mod.Settings.MinMissPercentage .. " to miss their target territory when their target is directly connected to the mortar", "Cyan");
			newLabel("maxMissPercentage", vert, "Mortars have a " .. Mod.Settings.MaxMissPercentage .. " to miss their target territory when their target is at maximum distance from the mortar", "Light Blue");
			newLabel("rangeOfMortars", vert, "Mortars are configured to have a range of " .. Mod.Settings.RangeOfMortars, "Cyan");
		else
			newLabel("noMortars", vert, "This game does not use Mortars", "Orange Red");
		end
	end
end