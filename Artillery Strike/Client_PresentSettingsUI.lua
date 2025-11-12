require("UI");
function Client_PresentSettingsUI(rootParent)
	Init();
	colors = GetColors();

	local root = CreateWindow(CreateVert(rootParent));

	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("Players get an artillery strike every " .. Mod.Settings.ArtilleryShot .. " turns").SetColor(colors.TextDefault);
	end, "Determines how frequent players can order an artillery strike. For example, if set to 5, players are able to target a territory with an artillery strike every 5 turns. If players do not use an artillery strike, it is saved up, players can have an unlimited number of unused artillery strikes");
	
	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("Artillery strikes cost gold: ").SetColor(colors.TextDefault);
		createBooleanLabel(line, Mod.Settings.UseGold);
	end, "");

	if Mod.Settings.UseGold then
		CreateInfoButtonLine(root, function(line)
			CreateLabel(line).SetText("Artillery Strike gold cost: ").SetColor(colors.TextDefault);
			CreateLabel(line).SetText(Mod.Settings.GoldCost).SetColor(colors.Aqua);
		end, "This is the cost to order an artillery strike. Every artillery strike will cost a player this amount of gold");
	end

	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("Cannons are enabled: ").SetColor(colors.TextDefault);
		createBooleanLabel(line, Mod.Settings.Cannons);
	end, "Cannons are 1 of the 2 artillery pieces in the mod. A player controlling a territory with a cannon is able to order an artillery strike");
	
	if Mod.Settings.Cannons then
		if Mod.Settings.CustomScenario then
			CreateInfoButtonLine(root, function(line)
				CreateLabel(line).SetText("Number of cannons: ").SetColor(colors.TextDefault);
				CreateLabel(line).SetText(0).SetColor(colors.Aqua);
			end, "The mod was configured to not add cannons to the map. All cannons in this game were added by other mods");
		else
			CreateInfoButtonLine(root, function(line)
				CreateLabel(line).SetText("Number of cannons: ").SetColor(colors.TextDefault);
				CreateLabel(line).SetText(Mod.Settings.AmountOfCannons).SetColor(colors.Aqua);
			end, "The mod will distribute " .. Mod.Settings.AmountOfCannons .. " at the start of the game. They will be assigned to random territories, and there will not be multiple cannons on the same territory.");
		end

		CreateInfoButtonLine(root, function(line)
			CreateLabel(line).SetText("Maximum cannon damage: ").SetColor(colors.TextDefault);
			CreateLabel(line).SetText(Mod.Settings.MaxCannonDamage).SetColor(colors.Aqua);
			CreateLabel(line).SetText("%").SetColor(colors.TextDefault);
		end, "The maximum % of damage cannons will inflict on their target territory. The final damage will depend on the distance between the cannon and its target, and will be equal or inbetween both maximum and minimum damage values. The further the target, the fewer damage is inflicted");
		
		CreateInfoButtonLine(root, function(line)
			CreateLabel(line).SetText("Minimum cannon damage: ").SetColor(colors.TextDefault);
			CreateLabel(line).SetText(Mod.Settings.MinCannonDamage).SetColor(colors.Aqua);
			CreateLabel(line).SetText("%").SetColor(colors.TextDefault);
		end, "The minimum % of damage cannons will inflict on their target territory. The final damage will depend on the distance between the cannon and its target, and will be equal or inbetween both maximum and minimum damage values. The further the target, the fewer damage is inflicted");
		
		CreateInfoButtonLine(root, function(line)
			CreateLabel(line).SetText("The maximum range of a cannon").SetColor(colors.TextDefault);
			CreateLabel(line).SetText(Mod.Settings.RangeOfCannons).SetColor(colors.Aqua);
		end, "The maximum distance between the cannon and its target. Note that the final damage will depend on the distance between the cannon and its target, and will be equal or inbetween both maximum and minimum damage values. The further the target, the fewer damage is inflicted");
	end

	CreateEmpty(root).SetMinHeight(5);

	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("Mortars are enabled: ").SetColor(colors.TextDefault);
		createBooleanLabel(line, Mod.Settings.Mortars);
	end, "Mortar are 1 of the 2 artillery pieces in the mod. A player controlling a territory with a mortar is able to order an artillery strike");

	if Mod.Settings.Mortars then
		if Mod.Settings.CustomScenario then
			CreateInfoButtonLine(root, function(line)
				CreateLabel(line).SetText("Number of Mortars: ").SetColor(colors.TextDefault);
				CreateLabel(line).SetText(0).SetColor(colors.Aqua);
			end, "The mod was configured to not add cannons to the map. All cannons in this game were added by other mods");
		else
			CreateInfoButtonLine(root, function(line)
				CreateLabel(line).SetText("Number of Mortars: ").SetColor(colors.TextDefault);
				CreateLabel(line).SetText(Mod.Settings.AmountOfMortars).SetColor(colors.Aqua);
			end, "The mod will distribute " .. Mod.Settings.AmountOfMortars .. " at the start of the game. They will be assigned to random territories, and there will not be multiple cannons on the same territory.");
		end

		CreateInfoButtonLine(root, function(line)
			CreateLabel(line).SetText("Damage of mortar: ").SetColor(colors.TextDefault);
			CreateLabel(line).SetText(Mod.Settings.MortarDamage).SetColor(colors.Aqua);
			CreateLabel(line).SetText("%").SetColor(colors.TextDefault);
		end, "Mortars inflict " .. Mod.Settings.MortarDamage .. "% damage, but not always on the target territory. The higher the miss chance and range, the more will be deducted from this number and applied to neighbouring territories");

		CreateInfoButtonLine(root, function(line)
			CreateLabel(line).SetText("Maximum miss chance: ").SetColor(colors.TextDefault);
			CreateLabel(line).SetText(Mod.Settings.MaxMissPercentage).SetColor(colors.Aqua);
			CreateLabel(line).SetText("%").SetColor(colors.TextDefault);
		end, "The maximum number that will be deducted from the mortar damage number, when the mortar shoots at a target at maximum range. The deducted number will inflict damage to neighbouring territories");
		
		CreateInfoButtonLine(root, function(line)
			CreateLabel(line).SetText("Minimum miss chance: ").SetColor(colors.TextDefault);
			CreateLabel(line).SetText(Mod.Settings.MinMissPercentage).SetColor(colors.Aqua);
			CreateLabel(line).SetText("%").SetColor(colors.TextDefault);
		end, "The minimum number that will be deducted from the mortar damage number, when the mortar shoots at a target at minimum range. The deducted number will inflict damage to neighbouring territories");
		
		CreateInfoButtonLine(root, function(line)
			CreateLabel(line).SetText("Maximum range of mortars: ").SetColor(colors.TextDefault);
			CreateLabel(line).SetText(Mod.Settings.RangeOfMortars).SetColor(colors.Aqua);
		end, "The maximum distance between the mortar and its target. The further the target, the more damage will be taken away from the target territory and will be applied to the neighbouring territories of the target territory");
	end

	CreateInfoButtonLine(root, function(line)
		CreateLabel(line).SetText("Do not place artillery: ").SetColor(colors.TextDefault);
		createBooleanLabel(line, Mod.Settings.CustomScenario);
	end, "If yes, this mod will not place any cannons and mortars on the map. Another mod should be used to place the required structures on the map. If no, the mod will distribute cannons and/or mortars depending on their settings.");
end

function createBooleanLabel(par, b)
	if b then
		CreateLabel(par).SetText("Yes").SetColor(colors.Green);
	else
		CreateLabel(par).SetText("No").SetColor(colors.OrangeRed);
	end
end

