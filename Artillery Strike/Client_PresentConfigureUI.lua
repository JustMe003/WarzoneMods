require("UI");

function Client_PresentConfigureUI(rootParent)
	Init();
	colors = GetColors();
	GlobalRoot = CreateVert(rootParent).SetCenter(true);

	showCannons();		-- initialize the default values or restore the values stored
	showMortars();		-- initialize the default values or restore the values stored
	showMiscelaneousSettings();		-- initialize the default values or restore the values stored

	showButtons();
	CreateEmpty(GlobalRoot).SetMinHeight(10);
	showDescription();
end

function showDescription()
	saveAll();
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetCenter(true);
	CreateLabel(root).SetText("Welcome to the Artillery Strike mod!").SetColor(colors.TextDefault);
	CreateEmpty(root).SetMinHeight(5);
	CreateLabel(root).SetText("This mod utilises the structures \"Cannons\" and \"Mortars\", in this mod referred to as artillery, from the idle version and provides functionality to them. Any cannon and mortar structure can be used as an artillery, it does not matter which mod added the structure and when this structure was added.").SetColor(colors.TextDefault);
	CreateEmpty(root).SetMinHeight(3);
	CreateLabel(root).SetText("All cannons and mortars have a maximum range. An artillery structure can only attack territories in this range. Cannons can have a different range than mortars").SetColor(colors.TextDefault).SetFlexibleWidth(1).SetAlignment(WL.TextAlignmentOptions.Left);
	CreateLabel(root).SetText("All cannons and all mortars do the same amount of % damage. On default, the further the target territory, the less damage an artillery strike will inflict although this is optional. Note again that cannons and mortars can deal a different % of damage").SetColor(colors.TextDefault).SetFlexibleWidth(1).SetAlignment(WL.TextAlignmentOptions.Left);
	CreateLabel(root).SetText("A special feature that only the mortars have is a miss chance. When a portion of a the artillery strike \"misses\" the target territory, they will inflict damage on territories connected to the target").SetColor(colors.TextDefault).SetFlexibleWidth(1).SetAlignment(WL.TextAlignmentOptions.Left);
end

function showCannons()
	saveAll();
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetFlexibleWidth(1);
	local line = CreateHorz(root);
	addCannons = CreateCheckBox(line).SetText(" ").SetIsChecked(Mod.Settings.Cannons or false).SetOnValueChanged(updateCannons);
	CreateLabel(line).SetText("Enable cannons").SetColor(colors.TextDefault);
	
	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("Number of territories to start with a cannon").SetColor(colors.TextDefault);
	end, "The number of territories that will be assigned a cannon structure. Note that if this value is greater than the number of territories available, the mod will assign all territories 1 cannon");
	maxCannons = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(Mod.Settings.AmountOfCannons or 20);
	
	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("Minimum % of damage inflicted by a cannon").SetColor(colors.TextDefault);
	end, "The minimum amount of damage that will be applied to the targetted territory. The damage is applied in percentages, meaning that the number of killed armies depends on the number of armies on the target territory");
	minimumCannonDamage = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(100).SetWholeNumbers(false).SetValue(Mod.Settings.MinCannonDamage or 20);
	
	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("Maximum % of damage inflicted by a cannon").SetColor(colors.TextDefault);
	end, "The maximum amount of damage that will be applied to the targetted territory. The damage is applied in percentages, meaning that the number of killed armies depends on the number of armies on the target territory");
	maximumCannonDamage = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(100).SetWholeNumbers(false).SetValue(Mod.Settings.MaxCannonDamage or 40);
	
	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("The range of cannons").SetColor(colors.TextDefault);
	end, "Sets the range of all cannons. Range determines how far a cannon can target a territory. With a range of 1, cannons can only target directly connected territories. With a range of 2, they can also target territories connected to their directly connected territories, etc. Note that the further a target is, the less damage will be inflicted by a cannon");
	rangeOfCannons = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(Mod.Settings.RangeOfCannons or 3);

	CreateButton(CreateHorz(root).SetCenter(true)).SetText("Save").SetColor(colors.Green).SetOnClick(function()
		saveCannons();
		updateCannons();
	end);

	updateCannons();
end

function showMortars()
	saveAll();
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetFlexibleWidth(1);
	local line = CreateHorz(root);
	addMortars = CreateCheckBox(line).SetText(" ").SetIsChecked(Mod.Settings.Mortars or false).SetOnValueChanged(updateMortars);
	CreateLabel(line).SetText("Enable mortars").SetColor(colors.TextDefault);

	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("Number of territories that start with a mortar").SetColor(colors.TextDefault);
	end, "The number of territories that will be assigned a mortar structure. Note that if this value is greater than the number of territories available, the mod will assign all territories 1 mortar");
	maxMortars = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(50).SetValue(Mod.Settings.AmountOfMortars or 20);

	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("Damage (%) inflicted by a mortar").SetColor(colors.TextDefault);
	end, "The damage inflicted by a mortar to the target territory. Note that depending on the miss chance this value will not always get fully applied");
	mortarDamage = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(100).SetValue(Mod.Settings.MortarDamage or 30);

	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("Minimum miss chance (%)").SetColor(colors.TextDefault);
	end, "Simulate how some of the shells miss their target territory. If a shell misses, it inflicts damage to a neighbouring territory. The miss chance is subtracted from the total mortar damage, and is divided over all the neighbouring territories of the target territory. Note that the miss percentage is influenced by how far the target territory is from the mortar, this value determines the minimum possible miss chance");
	minMissPercentage = CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(50).SetValue(Mod.Settings.MinMissPercentage or 10);

	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("Maximum miss chance (%)").SetColor(colors.TextDefault);
	end, "Simulate how some of the shells miss their target territory. If a shell misses, it inflicts damage to a neighbouring territory. The miss chance is subtracted from the total mortar damage, and is divided over all the neighbouring territories of the target territory. Note that the miss percentage is influenced by how far the target territory is from the mortar, this value determines the maximum possible miss chance");
	maxMissPercentage = CreateNumberInputField(root).SetSliderMinValue(0).SetSliderMaxValue(50).SetValue(Mod.Settings.MaxMissPercentage or 20);

	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("The range of mortars").SetColor(colors.TextDefault);
	end, "Sets the range of all mortars. The range determines how far a mortar can target a territory. With a range of 1, mortars can only target directly connected territories. With a range of 2, they can also target territories connected to their directly connected territories, etc. Note that the further a target is, the higher miss chance will be applied")
	rangeOfMortars = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(5).SetValue(Mod.Settings.RangeOfMortars or 3);

	-- CreateLabel(root).SetText(getMissPercentagesString()).SetColor(colors.TextDefault);
	CreateButton(CreateHorz(root).SetCenter(true)).SetText("Save").SetColor(colors.Green).SetOnClick(function()
		saveMortars();
		updateMortars();
	end);

	updateMortars();
end

function showMiscelaneousSettings()
	saveAll();
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot));
	
	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("How frequent players are able to use an artillery strike").SetColor(colors.TextDefault);
	end, "Determines how frequent players can order an artillery strike. For example, if set to 5, players are able to target a territory with an artillery strike every 5 turns. If players do not use an artillery strike, it is saved up, players can have an unlimited number of unused artillery strikes");
	cannonShotTurnNumber = CreateNumberInputField(root).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(Mod.Settings.ArtilleryShot or 5);

	CreateInfoButtonLine(root, function(l)
		useGoldInput = CreateCheckBox(l).SetText(" ").SetIsChecked(Mod.Settings.UseGold or false);
		CreateLabel(l).SetText("Players must use gold to order an artillery strike").SetColor(colors.TextDefault);
	end, "");
	
	CreateInfoButtonLine(root, function(l)
		CreateLabel(l).SetText("The gold cost for an artillery strike").SetColor(colors.TextDefault);
	end, "The amount of gold a player has to pay to order an artillery strike. One can see this as ammunition an service costs");
	goldCostInput = CreateNumberInputField(root).SetSliderMinValue(5).SetSliderMaxValue(25).SetValue(Mod.Settings.GoldCost or 10);

	CreateInfoButtonLine(root, function(l)
		customScenarioInput = CreateCheckBox(l).SetText(" ").SetIsChecked(Mod.Settings.CustomScenario or false);
		CreateLabel(l).SetText("Do not place cannons and mortars").SetColor(colors.TextDefault);
	end, "This option enables or disables whether the mod will place structures or not. This can be useful if you are using another mod that also places the same structures, for example, the \"Structures Distribution\" mod.");

	CreateButton(CreateHorz(root).SetCenter(true)).SetText("Save").SetColor(colors.Green).SetOnClick(function()
		saveMiscelaneous();
		updateMiscelaneousSettings();
	end);

	updateMiscelaneousSettings();
end

function updateCannons()
	local cannons = addCannons.GetIsChecked();
	maxCannons.SetInteractable(cannons);
	minimumCannonDamage.SetInteractable(cannons);
	maximumCannonDamage.SetInteractable(cannons);
	rangeOfCannons.SetInteractable(cannons);
end

function updateMortars()
	local mortars = addMortars.GetIsChecked();
	maxMortars.SetInteractable(mortars);
	mortarDamage.SetInteractable(mortars);
	minMissPercentage.SetInteractable(mortars);
	maxMissPercentage.SetInteractable(mortars);
	rangeOfMortars.SetInteractable(mortars);
end

function updateMiscelaneousSettings()
	goldCostInput.SetInteractable(useGoldInput.GetIsChecked());
end


function showButtons();
	local line = CreateHorz(GlobalRoot).SetCenter(true);
	CreateButton(line).SetText("General").SetColor(colors.Yellow).SetOnClick(showMiscelaneousSettings);
	CreateEmpty(line).SetMinWidth(5);
	CreateButton(line).SetText("Cannons").SetColor(colors.Aqua).SetOnClick(showCannons);
	CreateEmpty(line).SetMinWidth(5);
	CreateButton(line).SetText("Mortars").SetColor(colors.RoyalBlue).SetOnClick(showMortars);
	CreateEmpty(line).SetMinWidth(5);
	CreateButton(line).SetText("Info").SetColor(colors.Green).SetOnClick(showDescription);
end

function getMissPercentagesString()
	local str = "the percentages will be (from close to far):";
	local minPer = minMissPercentage.GetValue();
	local maxPer = maxMissPercentage.GetValue();
	local maxRange = rangeOfMortars.GetValue() - 1;
	local increment = (maxPer - minPer) / maxRange;
	for i = 0, maxRange do
		str = str .. " " .. (minPer + increment * i) .. ",";
	end
	return string.sub(str, 1, string.len(str)-1);
end
