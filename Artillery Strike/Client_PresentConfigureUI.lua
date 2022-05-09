require("UI");

function Client_PresentConfigureUI(rootParent)
	init(rootParent);

	setValues();
	showCannons();		-- initialize the default values or restore the values stored
	showMortars();		-- initialize the default values or restore the values stored
	showCommerceSettings();		-- initialize the default values or restore the values stored

	local win = "Main";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		showButtons();
		showDescription();
	end
	
end

function showDescription()
	local win = "Description";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		showButtons();
		local vert = newVerticalGroup(win .. " vert", "root");
		newLabel(win .. " line 1", vert, "This mod adds 2 new attack features, both long range\n", "Lime");
		newLabel(win .. " line 2", vert, "\nCannons:\n - Cannons are able to attack territories within a maximum range\n - Cannons work very similar to bomb cards, they remove a certain percentage of armies from a territory\n - The further the cannon is from its target, the less damage it does (can be avoided)\n", "Royal Blue");
		newLabel(win .. " line 3", vert, "\nMortars:\n - Mortars are able to attack territories within a maximum range\n - Mortars also work very similar to bomb cards, they remove a certain percentage of armies from a territory\n - Mortars have some extra options that makes them 'miss' the target territory and hit a connected territory", "Royal Blue")
	end
end

function showCannons()
	local win = "Cannons";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
		updateCannons();
	else
		destroyWindow(getCurrentWindow());
		window(win);
		showButtons();
		local vert = newVerticalGroup(win .. " vert", "root");
		local line = newHorizontalGroup(win .. " line", vert);
		addCannons = newCheckbox("addCannons", line, " ", cannons, true, updateCannons);
		newLabel("addCanonsLabel", line, "Add cannons to the game", "Lime");
		maxCannonsLabel = newLabel("maxCannonsLabel", vert, "Maximum amount of cannons\n(Note that the mod might overwrite this value depending on how many neutral territories there are)", getColorCannons());
		maxCannons = newNumberField("maxCannons", vert, 1, 50, numberOfCannons, cannons);
		minDamageCannonsLabel = newLabel("minDamageCannonsLabel", vert, "The minimum damage (in %) a cannon will inflict on a territory", getColorCannons());
		minimumCannonDamage = newNumberField("minimumCannonDamage", vert, 1, 100, cannonMinDamage, cannons);
		maxDamageCannonsLabel = newLabel("maxDamageCannonsLabel", vert, "The maximum damage (in %) a cannon will inflict on a territory", getColorCannons());
		maximumCannonDamage = newNumberField("maximumCannonDamage", vert, 1, 100, cannonMaxDamage, cannons);
		rangeOfCannonsLabel = newLabel("rangeOfCannonsLabel", vert, "The maximum range of cannons", getColorCannons());
		rangeOfCannons = newNumberField("rangeOfCannons", vert, 1, 5, cannonRange, cannons);
	end
end

function showMortars()
	local win = "Mortars";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
		updateMortars();
	else
		destroyWindow(getCurrentWindow());
		window(win);
		showButtons();
		local vert = newVerticalGroup(win .. " vert", "root");
		local line = newHorizontalGroup(win .. " line", vert);
		addMortars = newCheckbox("addMortars", line, " ", mortars, true, updateMortars);
		newLabel("addMortarsLabel", line, "Add mortars to the game", "Royal Blue");
		maxMortarsLabel = newLabel("maxMortarsLabel", vert, "Maximum amount of mortars\n(Note that the mod might overwrite this value depending on how many neutral territories there are)", getColorMortars());
		maxMortars = newNumberField("maxMortars", vert, 1, 50, numberOfMortars, mortars);
		damageMortarsLabel = newLabel("damageMortarsLabel", vert, "The damage (in %) a cannon will inflict on a territory", getColorMortars());
		mortarDamage = newNumberField("mortarDamage", vert, 1, 100, damageOfMortars, mortars);
		mortarMissExplanation = newLabel("mortarMissExplanation", vert, "\nMortars are more powerful than cannons but they do tend to miss their target sometimes. The further their target is, the bigger the chance a shell misses. \n\nNote that the minimum percentage applies for the closest territories (those directly connected to the territory of the mortar) and the maximum percentage applies to those territories that are at the maximum range\n\nSee [Description] for an extended explanation and see [Advanced settings] for examples\n", getColorMortars());
		minMissPercentageLabel = newLabel("minMissPercentageLabel", vert, "The chance of a mortar shot missing its target territory (minimum)", getColorMortars());
		minMissPercentage = newNumberField("minMissPercentage", vert, 1, 50, missPercentageMin, mortars);
		maxMissPercentageLabel = newLabel("maxMissPercentageLabel", vert, "The chance of a mortar shot missing its target territory (maximum)", getColorMortars());
		maxMissPercentage = newNumberField("maxMissPercentage", vert, 1, 50, missPercentageMax, mortars);
		mortarPercentageLabel = newLabel("mortarPercentageLabel", vert, " ", "#777777");
		rangeOfMortarsLabel = newLabel("rangeOfMortarsLabel", vert, "The range of mortars", getColorMortars());
		rangeOfMortars = newNumberField("rangeOfMortars", vert, 1, 5, mortarRange, mortars);
		updateText(mortarPercentageLabel, getMissPercentagesString());
		mortarRefreshButton = newButton("mortarRefreshButton", vert, "Refresh", function() updateText(mortarPercentageLabel, getMissPercentagesString()); end, "Green", mortars);
	end
end

function showCommerceSettings()
	local win = "commerce";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		showButtons();
		local vert = newVerticalGroup("vert", "root");
		newLabel("cannonShotTurnNumberLabel", vert, "Players can launch an artillery strike every X amount of turns", "Light Blue");
		cannonShotTurnNumber = newNumberField("cannonShotTurnNumber", vert, 1, 10, artilleryShot);
		local line = newHorizontalGroup("line1", vert);
		useGoldInput = newCheckbox("UseGold", line, " ", useGold, true, updateCommerceSettings);
		newLabel(win .. "descGold", line, "If commerce is enabled and checked, players have to use gold to launch an artillery strike", "Orange");
		goldCostDesc = newLabel(win .. "GoldCostLine", vert, "The amount of gold for a artillery strike", getColorCommerce());
		goldCostInput = newNumberField(win .. "GoldCost", vert, 10, 50, goldCost, getIsChecked(useGoldInput));
		line = newHorizontalGroup("line2", vert);
		customScenarioInput = newCheckbox(win .. "customScenarioInput", line, " ", customScenario);
		newLabel(win .. "CustomScenario", line, "Check this checkbox if this mod should not place any structures (for instance if you use the Structures for Custom Scenarios mod)", "Orange Red");
	end
end

function updateCannons()
	updateColor(maxCannonsLabel, getColorCannons());
	updateColor(rangeOfCannonsLabel, getColorCannons());
	updateColor(minDamageCannonsLabel, getColorCannons());
	updateColor(maxDamageCannonsLabel, getColorCannons());
	updateInteractable(maxCannons, getIsChecked(addCannons));
	updateInteractable(minimumCannonDamage, getIsChecked(addCannons));
	updateInteractable(maximumCannonDamage, getIsChecked(addCannons));
	updateInteractable(rangeOfCannons, getIsChecked(addCannons));
end

function updateMortars()
	updateColor(maxMortarsLabel, getColorMortars());
	updateColor(damageMortarsLabel, getColorMortars());
	updateColor(minMissPercentageLabel, getColorMortars());
	updateColor(maxMissPercentageLabel, getColorMortars());
	updateColor(rangeOfMortarsLabel, getColorMortars());
	updateColor(mortarMissExplanation, getColorMortars());
	updateColor(mortarPercentageLabel, getColorMortars());
	updateInteractable(maxMortars, getIsChecked(addMortars));
	updateInteractable(mortarDamage, getIsChecked(addMortars));
	updateInteractable(minMissPercentage, getIsChecked(addMortars));
	updateInteractable(maxMissPercentage, getIsChecked(addMortars));
	updateInteractable(rangeOfMortars, getIsChecked(addMortars));
	updateInteractable(mortarRefreshButton, getIsChecked(addMortars));
end

function updateCommerceSettings()
	updateColor(goldCostDesc, getColorCommerce());
	updateInteractable(goldCostInput, getIsChecked(useGoldInput));
end


function showButtons();
	local line = newHorizontalGroup(getCurrentWindow() .. " Buttons line", "root");
	newButton(getCurrentWindow() .. " Description button", line, "Description", showDescription, "Green");
	newButton(getCurrentWindow() .. " Commerce Settings", line, "General", showCommerceSettings, "Yellow");
	newButton(getCurrentWindow() .. " Cannons button", line, "Cannons", showCannons, "Aqua");
	newButton(getCurrentWindow() .. " Mortars button", line, "Mortars", showMortars, "Royal Blue");
end

function getMissPercentagesString()
	local str = "the percentages will be (from close to far):";
	local minPer = getValue(minMissPercentage);
	local maxPer = getValue(maxMissPercentage);
	local maxRange = getValue(rangeOfMortars) - 1;
	local increment = (maxPer - minPer) / maxRange;
	for i = 0, maxRange do
		str = str .. " " .. (minPer + increment * i) .. ",";
	end
	return string.sub(str, 1, string.len(str)-1);
end

function getColorCannons()
	if addCannons ~= nil then
		if getIsChecked(addCannons) then
			return "Lime";
		end
	end
	return "#777777";
end

function getColorMortars()
	if addMortars ~= nil then
		if getIsChecked(addMortars) then
			return "Royal Blue";
		end
	end
	return "#777777";
end

function getColorCommerce()
	if useGoldInput ~= nil then
		if getIsChecked(useGoldInput) then
			return "Orange";
		end
	end
	return "#777777";
end

function setValues()
	cannons = Mod.Settings.Cannons;	if cannons == nil then cannons = false; end
	numberOfCannons = Mod.Settings.AmountOfCannons; if numberOfCannons == nil then numberOfCannons = 20; end
	cannonMaxDamage = Mod.Settings.MaxCannonDamage; if cannonMaxDamage == nil then cannonMaxDamage = 25; end
	cannonMinDamage = Mod.Settings.MinCannonDamage; if cannonMinDamage == nil then cannonMinDamage = 10; end
	cannonRange = Mod.Settings.RangeOfCannons; if cannonRange == nil then cannonRange = 2; end
	mortars = Mod.Settings.Mortars; if mortars == nil then mortars = false; end
	numberOfMortars = Mod.Settings.AmountOfMortars; if numberOfMortars == nil then numberOfMortars = 20; end
	damageOfMortars = Mod.Settings.MortarDamage; if damageOfMortars == nil then damageOfMortars = 25; end
	missPercentageMin = Mod.Settings.MinMissPercentage; if missPercentageMin == nil then missPercentageMin = 10; end
	missPercentageMax = Mod.Settings.MaxMissPercentage; if missPercentageMax == nil then missPercentageMax = 25; end
	mortarRange = Mod.Settings.RangeOfMortars; if mortarRange == nil then mortarRange = 2; end
	artilleryShot = Mod.Settings.ArtilleryShot; if artilleryShot == nil then artilleryShot = 4; end
	useGold = Mod.Settings.UseGold; if useGold == nil then useGold = false; end
	goldCost = Mod.Settings.GoldCost; if goldCost == nil then goldCost = 20; end
	customScenario = Mod.Settings.CustomScenario; if customScenario == nil then customScenario = false; end
end
