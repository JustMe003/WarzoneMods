require("UI");
require("Utilities");
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	init(rootParent);
	Game = game;
	setMaxSize(500, 400);
	setSize = setMaxSize;
	
	showMenu();
end

function showMenu()
	local win = "Main";
	totalShots = getTotalRemainingShots();
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
		if Mod.Settings.UseGold == false then
			updateMainMenu();
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup(win .. "vert", "root");
		if Mod.Settings.UseGold == false then
			newLabel(win .. "label", vert, "You've got " .. totalShots .. " artillery strikes remaining", "Orange Red");
			newButton(win .. "Button", vert, "Artillery Strike", artilleryStrikeMenu, "Royal Blue", totalShots > 0);
			newLabel(win .. "label2", vert, Game.Game.TurnNumber - 1 - (Mod.PublicGameData.TotalArtilleryShots[Game.Us.ID] * Mod.Settings.ArtilleryShot) .. " / " .. Mod.Settings.ArtilleryShot, "Teal");
		else
			if not Game.Settings.CommerceGame then
				newLabel(win .. "label", vert, "The mod was configured to make an artillery strike cost gold but since commerce is disabled it cannot be used", "Orange Red");
			else
				newLabel(win .. "label", vert, "Launching an artillery costs " .. Mod.Settings.GoldCost .. " gold", "Orange");
				newButton(win .. "Button", vert, "Artillery Strike", artilleryStrikeMenu, "Royal Blue", Game.LatestStanding.NumResources(Game.Us.ID, WL.ResourceType.Gold) >= Mod.Settings.GoldCost);
			end
		end
	end
end

function updateMainMenu()
	local win = "Main";
	updateText(win .. "label", "You've got " .. totalShots .. " artillery strikes remaining");
	updateInteractable(win .. "Button", totalShots > 0);
	updateText(win .. "label2", totalShots *  Mod.Settings.ArtilleryShot + ((Game.Game.TurnNumber - 1) % Mod.Settings.ArtilleryShot) .. " / " .. Mod.Settings.ArtilleryShot);
end

function artilleryStrikeMenu()
	local win = "artilleryStrikeMenu";
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
		UI.InterceptNextTerritoryClick(showArtilleryOptions);
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup(win .. "vert", "root");
		newLabel(win .. "label", vert, "Click / tap the territory you want to hit\n", "Orange")
		newLabel(win .. "label2", vert, "Cannons always deal the same amount of damage to territories at the same distance.\nMortars however also deal damage to connected territories.", "Lime");
		UI.InterceptNextTerritoryClick(showArtilleryOptions);
		setSize(100, 100);
	end
end

function showArtilleryOptions(terrDetails)
	if terrDetails == nil then return; end
	setSize(500, 400);
	local win = "showArtilleryOptions" .. terrDetails.ID .. Game.Game.TurnNumber;
	if windowExists(win) then
		if getCurrentWindow() ~= win then
			destroyWindow(getCurrentWindow());
			restoreWindow(win);
		end
	else
		destroyWindow(getCurrentWindow());
		window(win);
		local vert = newVerticalGroup(win .. "vert", "root");
		local func1 = 	function(i, v)
							if Game.LatestStanding.Territories[i].FogLevel < 4 then
								return Game.LatestStanding.Territories[i].OwnerPlayerID == Game.Us.ID;
							end 
							return false;
						end
		if Mod.Settings.Cannons then
			newLabel(win .. "cannons", vert, "Cannons:", "Cyan");
			local func2 = 	function(i, v)
								if Game.LatestStanding.Territories[i].Structures ~= nil then
									if Game.LatestStanding.Territories[i].Structures[WL.StructureType.Attack] ~= nil then
										return Game.LatestStanding.Territories[i].Structures[WL.StructureType.Attack] > 0;
									end
								end
								return false;
							end
			local count = 0;
			for i, v in pairs(filter(filter(getTerritoriesInRange(Game, terrDetails.ID, Mod.Settings.RangeOfCannons), func1), func2)) do
				if count == 5 then break; end
				newButton(win .. "cannon" .. i, vert, Game.Map.Territories[i].Name .. ": " .. Mod.PublicGameData.DamageCannons[v] .. "%", function() shootCannon(terrDetails.ID, i, Mod.PublicGameData.DamageCannons[v]); end, "Orange")
				count = count + 1;
			end
		end
		if Mod.Settings.Mortars then
			newLabel(win .. "Mortars", vert, "Mortars:", "Royal Blue");
			local func2 = 	function(i, v)
								if Game.LatestStanding.Territories[i].Structures ~= nil then
									if Game.LatestStanding.Territories[i].Structures[WL.StructureType.Mortar] ~= nil then
										return Game.LatestStanding.Territories[i].Structures[WL.StructureType.Mortar] > 0;
									end
								end
								return false;
							end
			local count = 0;
			for i, v in pairs(filter(filter(getTerritoriesInRange(Game, terrDetails.ID, Mod.Settings.RangeOfMortars), func1), func2)) do
				if count == 5 then break; end
				newButton(win .. "cannon" .. i, vert, Game.Map.Territories[i].Name .. ": " .. Mod.Settings.MortarDamage .. " - " .. Mod.PublicGameData.MissPercentages[v] .. "%", function() shootMortar(terrDetails.ID, i, Mod.PublicGameData.MissPercentages[v]); end, "Orange")
				count = count + 1;
			end
		end
		newButton(win .. "return", vert, "Return", showMenu, "Green");
	end
end


function shootCannon(target, from, amount)
	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, "artillery strike from cannon at " .. Game.Map.Territories[from].Name .. " on " .. Game.Map.Territories[target].Name .. " for " .. amount .. "%", "Artillery Strike_Cannon_" .. target .. "_" .. from .. "_" .. amount, createResTable()));
	Game.Orders = orders;
	totalShots = totalShots - 1;
	showMenu();
end

function shootMortar(target, from, amount)
	local orders = Game.Orders;
	table.insert(orders, WL.GameOrderCustom.Create(Game.Us.ID, "artillery strike from mortar at " .. Game.Map.Territories[from].Name .. " on " .. Game.Map.Territories[target].Name, "Artillery Strike_Mortar_" .. target .. "_" .. from .. "_" .. amount, createResTable()));
	Game.Orders = orders;
	totalShots = totalShots - 1;
	showMenu();
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