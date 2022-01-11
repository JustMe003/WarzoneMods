require("UI")

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
	init();
	colors = initColors();
	Game = game; --global variables
	
	LastTurn = {};   --we get the orders from History later
	Distribution = {};	
	
	setMaxSize(450, 300);
	if (not game.Settings.LocalDeployments) then
		return createLabel(vert, "This mod only works in Local Deployment games. This isn't a Local Deployment.", colors.ErrorColor)
	elseif (not game.Us or game.Us.State ~= WL.GamePlayerState.Playing) then
		return createLabel(vert, "You cannot do anything since you're not in the game.", colors.ErrorColor);
	end

	vert = UI.CreateVerticalLayoutGroup(rootParent);
	permanentLabel1 = UI.CreateHorizontalLayoutGroup(vert);
	permanentLabel2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(permanentLabel1).SetText("Mod author:\t").SetColor(colors.TextColor);
	UI.CreateLabel(permanentLabel1).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
	UI.CreateLabel(permanentLabel2).SetText("Special thanks to:\t").SetColor(colors.TextColor);
	UI.CreateLabel(permanentLabel2).SetText("TBest").SetColor("#800080");
	showMenu();
end

function showMenu()
	init();
	if Mod.Settings.DeployTransferHelper == true then
		createButton(vert, "Go to deploy/transfer helper", "#00ff05", function() destroyAll(); showHelperMenu(); end);
		createButton(vert, "Clear Orders", "#0000FF", clearOrdersFunction);
	else
		if Game.Us ~= nil and not Game.Us.IsAIOrHumanTurnedIntoAI then
			createLabel(vert, "You can not use the deploy / transfer helper since you're not in the game (anymore)", colors.FalseColor);
		end
	end
	createButton(vert, "Settings", "#3333FF", showSettings);
	createButton(vert, "Credits", "#88FF00", showCredits);
end

function showCredits()
	init();
	
end

function showHelperMenu()
	init();
	line = getNewHorz(vert);
	line = getNewHorz(vert);
	addDeployments = createCheckBox(line, true, " ");
	createLabel(line, "Add deployments", colors.TextColor);
	createButton(line, "?", colors.Green, function() UI.Alert("When checked your deployments from the previous turn will be added to your orderlist") end)
	line = getNewHorz(vert);
	addTransfers = createCheckBox(line, false, " ");
	createLabel(line, "Add transfers", colors.TextColor);
	createButton(line, "?", colors.Green, function() UI.Alert("When checked your transfers from the previous turn will be added to your orderlist") end)
	line = getNewHorz(vert);
	setToPercentage = createCheckBox(line, false,  " ");
	createLabel(line, "overwrite all attacks/transfers to 100% orders", colors.TextColor);
	createButton(line, "?", colors.Green, function() UI.Alert("When checked all your transfers will be overwritten to 100% attacks/transfers. This will allow every army to be transferred, no matter the amount of armies") end)
	line = getNewHorz(vert);
	addAttacks = createCheckBox(line, false, " ");
	createLabel(line, "Add attacks", colors.TextColor);
	createButton(line, "?", colors.Green, function() UI.Alert("When checked your attacks from the previous turn will be added if you still control the attacking territory") end)
	addOrdersButton = createButton(vert, "Add orders", colors.Green, function() AddOrdersHelper(); destroyAll(); showMenu(); end);
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
	local standing = Game.LatestStanding; --used to make sure we can make the depoly/transfear
	local orderTabel = Game.Orders;--get client order list
	if next(orderTabel) ~= nil then --make sure we don't have past orders, since that is alot of extra work
		UI.Alert('Please clear your order list before using this mod.')
		return;
	end
	
	
	local maxDeployBonuses = {}; --aray with the bonuses
	for _, bonus in pairs (Game.Map.Bonuses) do
		maxDeployBonuses[bonus.ID] = bonus.Amount --store the bonus value
	end
	
	local newOrder;
	
	for _,order in pairs(LastTurn) do
		if order.PlayerID == Game.Us.ID then
			if order.proxyType == "GameOrderDeploy" and addDeployments.GetIsChecked() == true then
					--check that we own the territory
				if Game.Us.ID == standing.Territories[order.DeployOn].OwnerPlayerID then
					--check that we have armies to deploy
					local bonusID;
					for i, bonus in ipairs(Game.Map.Territories[order.DeployOn].PartOfBonuses) do
						if bonusValue(bonus) ~= 0 then
							bonusID = bonus;
							break;
						end
					end
					--make sure we deploy more then 0
					if ownsBonus(bonusID) and order.NumArmies > 0 then
						if maxDeployBonuses[bonusID] - order.NumArmies >=0 then --deploy full
							maxDeployBonuses[bonusID] = maxDeployBonuses[bonusID] - order.NumArmies
							newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, order.NumArmies, order.DeployOn, false);
							table.insert(orderTabel, newOrder);
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
						if setToPercentage.GetIsChecked() == false then
							newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, order.ByPercent, order.NumArmies, false);
						else
							newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, true, WL.Armies.Create(100, {}), false);
						end
						table.insert(orderTabel, newOrder);
					end
				end
			elseif order.proxyType == "GameOrderAttackTransfer" and addAttacks.GetIsChecked() == true then
				if Game.Us.ID == standing.Territories[order.From].OwnerPlayerID then
					if setToPercentage.GetIsChecked() == false then
						newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, order.ByPercent, order.NumArmies, false);
					else
						newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, true, WL.Armies.Create(100, {}), false);
					end
				end
			end
		end
	end
	--update client orders list
	Game.Orders = orderTabel;
end;

function AddOrdersHelper()
	standing = Game.LatestStanding; --used to make sure we can make the depoly/transfer
	LastTurn = Game.Orders

	--can we get rid of this Call?
	Game.GetDistributionStanding(function(data) getDistHelper(data)  end)

	local turn = Game.Game.TurnNumber;
	local firstTurn = 1;
	if (Distribution == nil) then --auto dist
		firstTurn = 0;
	end;
	if(turn - 1 <= firstTurn) then
		UI.Alert("You can't use the mod during distribution or for the first turn.");
		return;
	end;
	
	local turn = turn -2;
	print('request Game.GetTurn for turn: ' .. turn);
	Game.GetTurn(turn, function(data) getTurnHelperAddOrders(data) end)--getTurnHelperAdd(data) end)
end;

function getTurnHelperAddOrders(prevTurn)
	print('got prevTurn');
	LastTurn = prevTurn.Orders;
	AddOrdersConfirmes();
end;

--Your function will be called with nil if the distribution standing is not available, 
--for example if it's an automatic distribution game
function getDistHelper(data)
	print('got Distribution');
	Distribution = data;
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
	return Game.Map.Bonuses[bonusID].Amount;
end