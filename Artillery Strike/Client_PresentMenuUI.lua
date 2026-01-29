require("UI");
require("Utilities");

---comment
---@param rootParent RootParent
---@param setMaxSize fun(width: number, height: number)
---@param setScrollable fun(vert: boolean, horz: boolean)
---@param game GameClientHook
---@param close fun()
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	if game.Us == nil then return; end
	Init();
	colors = GetColors();
	GlobalRoot = CreateVert(rootParent).SetFlexibleWidth(1);
	Game = game;
	setMaxSize(500, 400);
	setSize = setMaxSize;
	if game.Game.TurnNumber < 1 then
		UI.Alert("This mod cannot be used in the distribution turn");
		close();
		return;
	end
	showMenu();
end

function showMenu()
	DestroyWindow();
	totalShots = getTotalRemainingShots();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetFlexibleWidth(1);
	if Mod.Settings.UseGold == false then
		local line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Artillery strikes remaining: ").SetColor(colors.TextDefault);
		CreateLabel(line).SetText(totalShots).SetColor((function() if totalShots > 0 then return colors.Green; else return colors.OrangeRed; end end)());

		line = CreateHorz(root).SetFlexibleWidth(1);
		CreateButton(line).SetText("Artillery Strike").SetOnClick(artilleryStrikeMenu).SetColor(colors.Orange).SetInteractable(totalShots > 0);
		CreateEmpty(line).SetFlexibleWidth(1);
		CreateButton(line).SetText("Target Finder").SetOnClick(targetFinderMenu).SetColor(colors.RoyalBlue);

		CreateLabel(root).SetText("You can order an additional artillery strike every " .. Mod.Settings.ArtilleryShot .. " turns").SetColor(colors.TextDefault);
	else
		if not Game.Settings.CommerceGame then
			CreateLabel(root).SetText("An artillery strike cost gold, but this game is not a commerce game. Therefore players will unfortunately not be able to use this mod").SetColor(colors.OrangeRed);
		else
			local line = CreateHorz(root).SetFlexibleWidth(1);
			CreateLabel(line).SetText("Artillery Strike cost: ").SetColor(colors.TextDefault);
			CreateLabel(line).SetText(Mod.Settings.GoldCost).SetColor(colors.Yellow);

			CreateButton(root).SetText("Artillery Strike").SetOnClick(artilleryStrikeMenu).SetColor(colors.Orange);
		end
	end
end

function targetFinderMenu()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetFlexibleWidth(1);

	CreateLabel(root).SetText("Select a territory with an artillery structure").SetColor(colors.TextDefault);
	
	UI.InterceptNextTerritoryClick(targetFinder);
	setSize(300, 300);
end

function targetFinder(terrDetails)
	if terrDetails == nil then return WL.CancelClickIntercept; end
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetFlexibleWidth(1).SetCenter(true);
	
	local showRange = function(range)
		local l = {};
		for i, _ in pairs(getTerritoriesInRange(Game, terrDetails.ID, range)) do
			table.insert(l, i);
		end
		Game.HighlightTerritories(l);
	end

	CreateButton(CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("Return").SetColor(colors.Orange).SetOnClick(targetFinderMenu);

	if not ((terrHasCannon(terrDetails.ID) and Mod.Settings.Cannons) or (terrHasMortar(terrDetails.ID) and Mod.Settings.Mortars)) then
		CreateLabel(root).SetText("This territory does not have an artillery structure").SetColor(colors.TextDefault);
	elseif (terrHasCannon(terrDetails.ID) and Mod.Settings.Cannons) and (terrHasMortar(terrDetails.ID) and Mod.Settings.Mortars) then
		CreateLabel(root).SetText("This territory has both a cannon and a mortar. Please select one of the buttons to highlight all possible targets for the respective artillery structure").SetColor(colors.TextDefault);
		
		local line = CreateHorz(root).SetFlexibleWidth(1).SetCenter(true);
		CreateButton(line).SetText("Cannon").SetColor(colors.Aqua).SetOnClick(function() showRange(Mod.Settings.RangeOfCannons) end);
		CreateButton(line).SetText("Mortar").SetColor(colors.RoyalBlue).SetOnClick(function() showRange(Mod.Settings.RangeOfMortars) end);
	elseif terrHasCannon(terrDetails.ID) and Mod.Settings.Cannons then
		CreateLabel(root).SetText("All possible targets of this cannon are now highlighted")
		showRange(Mod.Settings.RangeOfCannons);
	else
		CreateLabel(root).SetText("All possible targets of this mortar are now highlighted")
		showRange(Mod.Settings.RangeOfMortars);
	end
end

function artilleryStrikeMenu()
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetFlexibleWidth(1);

	CreateLabel(root).SetText("Select target territory").SetColor(colors.TextDefault);
	-- newLabel(win .. "label2", vert, "Cannons always deal the same amount of damage to territories at the same distance.\nMortars however also deal damage to connected territories.", "Lime");
	UI.InterceptNextTerritoryClick(showArtilleryOptions);
	setSize(300, 300);
end

function showArtilleryOptions(terrDetails)
	if terrDetails == nil then return WL.CancelClickIntercept; end
	setSize(400, 500);
	DestroyWindow();
	local root = CreateWindow(CreateVert(GlobalRoot)).SetFlexibleWidth(1).SetCenter(true);
	
	CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMenu);
	CreateLabel(root).SetText("Select which artillery you want to use").SetColor(colors.TextDefault);

	if Mod.Settings.Cannons then
		CreateEmpty(root).SetPreferredHeight(5);
		local line = CreateHorz(root).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Cannons").SetColor(colors.TextDefault);
		CreateEmpty(line).SetFlexibleWidth(1);
		CreateLabel(line).SetText("Damage").SetColor(colors.TextDefault);
		local cannons = filter(filter(getTerritoriesInRange(Game, terrDetails.ID, Mod.Settings.RangeOfCannons), terrHasCannon), terrIsOwnedByUs);
		if tableIsEmpty(cannons) then
			CreateLabel(root).SetText("You do not have any cannons that are in range of the current selected territory").SetColor(colors.OrangeRed);
			else
				local sortedCannons = convertRangeTable(cannons);
				table.sort(sortedCannons, sortOnRange);
				for _, cannon in ipairs(sortedCannons) do
					line = CreateHorz(root).SetFlexibleWidth(1);
					CreateButton(line).SetText(Game.Map.Territories[cannon.TerrID].Name).SetColor(Game.Us.Color.HtmlColor).SetOnClick(function()
						shootCannon(terrDetails.ID, cannon.TerrID, Mod.PublicGameData.DamageCannons[cannon.Range]);
					end);
					CreateEmpty(line).SetFlexibleWidth(1);
					CreateLabel(line).SetText(Mod.PublicGameData.DamageCannons[cannon.Range] .. "%").SetColor(colors.Ivory).SetMinWidth(60).SetAlignment(WL.TextAlignmentOptions.Right);
				end
			end
		end
		
		if Mod.Settings.Mortars then
			CreateEmpty(root).SetPreferredHeight(5);
			local line = CreateHorz(root).SetFlexibleWidth(1);
			CreateLabel(line).SetText("Mortars").SetColor(colors.TextDefault);
			CreateEmpty(line).SetFlexibleWidth(1);
			CreateLabel(line).SetText("Damage").SetColor(colors.TextDefault);
			local mortars = filter(filter(getTerritoriesInRange(Game, terrDetails.ID, Mod.Settings.RangeOfMortars), terrHasMortar), terrIsOwnedByUs);
			
			if tableIsEmpty(mortars) then
				CreateLabel(root).SetText("You do not have any mortars that are in range of the current selected territory").SetColor(colors.OrangeRed);
		else
			local sortedMortars = convertRangeTable(mortars);
			table.sort(sortedMortars, sortOnRange)
			for _, mortar in ipairs(sortedMortars) do
				line = CreateHorz(root).SetFlexibleWidth(1);
				CreateButton(line).SetText(Game.Map.Territories[mortar.TerrID].Name).SetColor(Game.Us.Color.HtmlColor).SetOnClick(function()
					shootMortar(terrDetails.ID, mortar.TerrID, Mod.PublicGameData.MissPercentages[mortar.Range]);
				end);
				CreateEmpty(line).SetFlexibleWidth(1);
				CreateLabel(line).SetText(Mod.Settings.MortarDamage - Mod.PublicGameData.MissPercentages[mortar.Range] .. "%, " .. Mod.PublicGameData.MissPercentages[mortar.Range] .. "%").SetColor(colors.Ivory).SetMinWidth(60).SetAlignment(WL.TextAlignmentOptions.Right);
			end
		end
	end
end

function terrHasCannon(terrID, _)
	return terrHasStructure(terrID, WL.StructureType.Attack);
end

function terrHasMortar(terrID, _)
	return terrHasStructure(terrID, WL.StructureType.Mortar);
end

function terrHasStructure(terrID, struct)
	local structures = Game.LatestStanding.Territories[terrID].Structures
	return structures and structures[struct] and structures[struct] > 0;
end

function terrIsOwnedByUs(terrID, _)
	return Game.LatestStanding.Territories[terrID].OwnerPlayerID == Game.Us.ID;
end


function shootCannon(target, from, amount)
	addOrderToOrderlist(WL.GameOrderCustom.Create(Game.Us.ID, "artillery strike from cannon at " .. Game.Map.Territories[from].Name .. " on " .. Game.Map.Territories[target].Name .. " for " .. amount .. "%", "Artillery Strike_Cannon_" .. target .. "_" .. from .. "_" .. amount, createResTable(), WL.TurnPhase.BombCards));
	totalShots = totalShots - 1;
	showMenu();
end

function shootMortar(target, from, amount)
	addOrderToOrderlist(WL.GameOrderCustom.Create(Game.Us.ID, "artillery strike from mortar at " .. Game.Map.Territories[from].Name .. " on " .. Game.Map.Territories[target].Name, "Artillery Strike_Mortar_" .. target .. "_" .. from .. "_" .. amount, createResTable(), WL.TurnPhase.BombCards));
	totalShots = totalShots - 1;
	showMenu();
end

function addOrderToOrderlist(order)
	local orders = Game.Orders;
    local index = 0;
    for i, o in pairs(orders) do
        if o.OccursInPhase ~= nil and o.OccursInPhase > WL.TurnPhase.Deploys then
            index = i;
            break;
        end
    end
    if index == 0 then index = #orders + 1; end
	table.insert(orders, index, order);
    Game.Orders = orders;
end

function getTotalRemainingShots()
	local total = math.floor((Game.Game.TurnNumber - 1) / Mod.Settings.ArtilleryShot) - Mod.PublicGameData.TotalArtilleryShots[Game.Us.ID];
	for _, order in pairs(Game.Orders) do
		if order.proxyType == "GameOrderCustom" then
			if string.find(order.Payload, "Artillery Strike_") ~= nil then
				total = total - 1;
			end
		end
	end
	return total;
end

function createResTable()
	if not Game.Settings.CommerceGame then return nil; end
	if Mod.Settings.UseGold then
		local t = {};
		t[WL.ResourceType.Gold] = Mod.Settings.GoldCost;
		return t;
	else
		return nil;
	end
end

function convertRangeTable(t)
	local ret = {};
	for index, range in pairs(t) do
		table.insert(ret, {TerrID = index; Range = range});
	end
	return ret;
end

function sortOnRange(t1, t2)
	return t1.Range < t2.Range;
end