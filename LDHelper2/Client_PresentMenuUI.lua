require("UI")

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	init();
	colors = initColors();
	Game = game; --global variables
	Close = close;
	
	LastTurn = {};   --we get the orders from History later
	Distribution = {};	
	
	setMaxSize(500, 420);
	
	vert = UI.CreateVerticalLayoutGroup(rootParent);
	if (not game.Settings.LocalDeployments) then
		return createLabel(vert, "This mod only works in Local Deployment games. This isn't a Local Deployment game", colors.ErrorColor)
	elseif (not game.Us or game.Us.State ~= WL.GamePlayerState.Playing) then
		return createLabel(vert, "You cannot do anything since you're not in the game.", colors.ErrorColor);
	end

	permanentLabel1 = UI.CreateHorizontalLayoutGroup(vert);
	permanentLabel2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(permanentLabel1).SetText("Mod author:\t").SetColor(colors.TextColor);
	UI.CreateLabel(permanentLabel1).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
	UI.CreateLabel(permanentLabel2).SetText("Special thanks to:\t").SetColor(colors.TextColor);
	UI.CreateLabel(permanentLabel2).SetText("TBest").SetColor(colors.Purple);
	if game.Us == nil then return; end
	if game.Us.IsAIOrHumanTurnedIntoAI then return; end
	showMenu();
end

function showMenu()
	init();
	if Mod.Settings.DeployTransferHelper == true then
		createButton(vert, "Go to deploy/transfer helper", "#00ff05", function() destroyAll(); showHelperMenu(); end);
		if Game.Game.TurnNumber == 1 then
			createButton(vert, "Deploy in all bonuses of size 1", "#AC0059", addDeploysTurnOne)
		end
		createButton(vert, "Clear Orders", "#0000FF", clearOrdersFunction);
	else
		if Game.Us ~= nil and not Game.Us.IsAIOrHumanTurnedIntoAI then
			createLabel(vert, "You can not use the deploy / transfer helper since you're not in the game (anymore)", colors.FalseColor);
		end
	end
	createButton(vert, "Settings", colors["Orange Red"], showSettings);
	createButton(vert, "Credits", colors.Orange, showCredits);
end

function showCredits()
	init();
	createLabel(vert, "Testers:", colors.TextColor)
	line = getNewHorz(vert);
	createLabel(line, "JK_3", colors.Green)
	createLabel(line, "krinid", colors.TyrianPurple)
	line = getNewHorz(vert);
	createLabel(line, "El Teoremas", colors.DarkMagenta)
	createLabel(line, "Zazzlegut", colors.Green)
end

function addDeploysTurnOne()
	local orders = Game.Orders;
	if #orders > 0 then
		UI.Alert("Remove all orders from your order list to use this");
		Close();
		return;
	end

	for bonusID, worth in pairs(Game.Us.Income(0, Game.LatestStanding, false, false).BonusRestrictions) do
		if #Game.Map.Bonuses[bonusID].Territories == 1 then
			print(Game.Map.Bonuses[bonusID].Name, worth);
			table.insert(orders, WL.GameOrderDeploy.Create(Game.Us.ID, worth, Game.Map.Bonuses[bonusID].Territories[1], false));
		end
	end
	
	Game.Orders = orders;
end

function showHelperMenu()
	if Game.Game.TurnNumber < 2 then
		UI.Alert("You cannot use the helper function in the distribution phase or in turn 1");
		Close();
		return;
	end
	
	init();
	createLabel(vert, "\n", colors.TextColor);
	line = getNewHorz(vert);
	addDeployments = createCheckBox(line, true, " ");
	createLabel(line, "Add deployments", colors.TextColor);
	createButton(line, "?", colors.Green, function() UI.Alert("When checked your deployments from the previous turn will be added to your orderlist") end)
	line = getNewHorz(vert);
	addTransfers = createCheckBox(line, false, " ");
	createLabel(line, "Add transfers", colors.TextColor);
	createButton(line, "?", colors.Green, function() UI.Alert("When checked your transfers from the previous turn will be added to your orderlist") end)
	line = getNewHorz(vert);
	setToPercentage = createCheckBox(line, false,  " ", Game.Settings.AllowPercentageAttacks);
	createLabel(line, "overwrite all attacks/transfers to percentage orders", colors.TextColor);
	createButton(line, "?", colors.Green, function() UI.Alert("When checked all your transfers will be overwritten to 100% attacks/transfers. This will allow every army to be transferred, no matter the amount of armies") end)
	line = getNewHorz(vert);
	addAttacks = createCheckBox(line, false, " ");
	createLabel(line, "Add attacks", colors.TextColor);
	createButton(line, "?", colors.Green, function() UI.Alert("When checked your attacks from the previous turn will be added if you still control the attacking territory") end)
	createLabel(vert, "\n", colors.TextColor);
	addOrdersButton = createButton(vert, "Add orders", colors.Green, function() AddOrdersHelper(); destroyAll(); showMenu(); end);
	setToPercentage.SetInteractable(Game.Settings.AllowPercentageAttacks);
end

function showSettings()
	init();
	if Mod.Settings.BonusOverrider == true then
		createLabel(vert, "This game makes use of the automatic bonus overrider", colors.TrueColor)
	else
		createLabel(vert, "This game did not makes use of the automatic bonus overrider", colors.FalseColor)
	end
	if Mod.Settings.DeployTransferHelper == true then
		createLabel(vert, "In this game you're able to use the deploy/transfer helper", colors.TrueColor)
	else
		createLabel(vert, "In this game you're not able to use the deploy/transfer helper", colors.FalseColor)
	end
	if Mod.Settings.OverridePercentage == true then
		createLabel(vert, "The mod has overridden the 'can attack by percentage' setting to be enabled", colors.TrueColor)
	else
		createLabel(vert, "The mod has not overriden the 'can attack by percentage' setting, the option can be either on or off", colors.FalseColor)
	end
	
end

function clearOrdersFunction()
	if Game.Us.HasCommittedOrders then
		return UI.Alert("You need to uncommit first");
	end
	local orderTabel = Game.Orders;--get client order list

	if next(orderTabel) ~= nil then
		orderTabel = {}
		Game.Orders = orderTabel
	end
end;

function AddOrdersConfirmes()	
	print ('running addOrders');
	if Game.Us.HasCommittedOrders == true then
		UI.Alert("You need to uncommit first");
		return;
	end
	
	local hasAttacksTransfers = false;
	local hasDeploys = false;
	local otherOrders = false;
	
	for _, order in pairs(Game.Orders) do
		if order.proxyType == "GameOrderDeploy" then
			hasDeploys = true;
		elseif order.proxyType == "GameOrderAttackTransfer" then
			hasAttacksTransfers = true;
		else
			otherOrders = true;
		end
	end
	
	local standing = Game.LatestStanding; --used to make sure we can make the depoly/transfear
	local orderTabel = Game.Orders;--get client order list
	if hasDeploys and addDeployments.GetIsChecked() then --make sure we don't have past orders, since that is alot of extra work
		UI.Alert('Please clear all your deployment orders before using the deployment helper function')
		return;
	end
	if hasAttacksTransfers and addDeployments.GetIsChecked() then
		UI.Alert("Please clear all orders before using the deployment helper function");
		return;
	end
	if otherOrders then
		UI.Alert("Please remove all orders that are not deployment or attacks / transfers from your order list to use the helper function");
		return;
	end
	
	local maxDeployBonuses = Game.Us.Income(0, Game.LatestStanding, false, false).BonusRestrictions;
--	local maxDeployBonuses = {}; --aray with the bonuses
	-- for _, bonus in pairs (Game.Map.Bonuses) do
		-- maxDeployBonuses[bonus.ID] = bonusValue(bonus.ID); --store the bonus value
	-- end
	
	local newOrder;
	
	for _,order in pairs(LastTurn) do
		if order.PlayerID == Game.Us.ID then
			if order.proxyType == "GameOrderDeploy" and addDeployments.GetIsChecked() == true then
					--check that we own the territory
				if Game.Us.ID == standing.Territories[order.DeployOn].OwnerPlayerID then
					--check that we have armies to deploy
					local bonusID = -1;
					for i, bonus in ipairs(Game.Map.Territories[order.DeployOn].PartOfBonuses) do
						if bonusValue(bonus) ~= 0 then
							bonusID = bonus;
							break;
						end
					end
					--make sure we deploy more then 0
					if bonusID ~= -1 and ownsBonus(bonusID) and order.NumArmies > 0 and maxDeployBonuses[bonusID] ~= nil then
						if maxDeployBonuses[bonusID] - order.NumArmies >=0 then --deploy full
							newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, order.NumArmies, order.DeployOn, false);
							table.insert(orderTabel, newOrder);
							maxDeployBonuses[bonusID] = maxDeployBonuses[bonusID] - order.NumArmies
						elseif maxDeployBonuses[bonusID] > 0 then --deploy the max we can
							newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, maxDeployBonuses[bonusID], order.DeployOn, false);
							table.insert(orderTabel, newOrder);
							maxDeployBonuses[bonusID] = 0;
						end
					end
				end
			end
			if (order.proxyType == "GameOrderAttackTransfer") and addTransfers.GetIsChecked() == true then
				if (Game.Us.ID == standing.Territories[order.From].OwnerPlayerID) then --from us 
					if (Game.Us.ID == standing.Territories[order.To].OwnerPlayerID) then -- to us
						if setToPercentage.GetIsChecked() and Game.Settings.AllowPercentageAttacks then
							if order.ByPercent then
								newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, true, WL.Armies.Create(order.NumArmies.NumArmies, {}), false);
							else
								newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, true, WL.Armies.Create(100, {}), false);
							end
						else
							newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, order.ByPercent, order.NumArmies, false);
						end
						if not orderExists(newOrder) then
							table.insert(orderTabel, newOrder);
						end
					end
				end
			elseif order.proxyType == "GameOrderAttackTransfer" and addAttacks.GetIsChecked() == true then
				if Game.Us.ID == standing.Territories[order.From].OwnerPlayerID then
					if setToPercentage.GetIsChecked() and Game.Settings.AllowPercentageAttacks then
						if order.ByPercent then
							newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, true, WL.Armies.Create(order.NumArmies.NumArmies, {}), false);
						else
							newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, true, WL.Armies.Create(100, {}), false);
						end					
					else
						newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, order.ByPercent, order.NumArmies, false);
					end
					if not orderExists(newOrder) then
						table.insert(orderTabel, newOrder);
					end
				end
			end
		end
	end
	--update client orders list
	Game.Orders = orderTabel;
--	Close();
end;

function AddOrdersHelper()
	Close();
	standing = Game.LatestStanding; --used to make sure we can make the depoly/transfer
	LastTurn = Game.Orders

	
	Game.GetTurn(Game.Game.TurnNumber - 2, function(data) getTurnHelperAddOrders(data) end)--getTurnHelperAdd(data) end)
end;

function getTurnHelperAddOrders(prevTurn)
	print('got prevTurn');
	LastTurn = prevTurn.Orders;
	AddOrdersConfirmes();
end;

function ownsBonus(bonusID)
	for _, terrID in pairs(Game.Map.Bonuses[bonusID].Territories) do
		if Game.LatestStanding.Territories[terrID].OwnerPlayerID ~= Game.Us.ID then 
			return false; 
		end
	end
	return true;
end

function bonusValue(bonusID)
	if Game.Settings.OverriddenBonuses ~= nil then
		if Game.Settings.OverriddenBonuses[bonusID] ~= nil then
			return Game.Settings.OverriddenBonuses[bonusID];
		end
	end
	return Game.Map.Bonuses[bonusID].Amount;
end

function orderExists(newOrder)
	for _, order in pairs(Game.Orders) do
		if order.proxyType == newOrder.proxyType then
			if order.proxyType == "GameOrderAttackTransfer" then
				if order.To == newOrder.To and order.From == newOrder.From then
					return true;
				end
			elseif order.proxyType == "GameOrderDeploy" then
				if order.DeployOn == newOrder.DeployOn then
					return true;
				end
			end
		end
	end
	return false;
end