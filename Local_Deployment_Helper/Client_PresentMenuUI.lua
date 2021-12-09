function SetTextColors()
	list = {}
	list.TextColor = "#AAAAAA"; list.ErrorColor = "#FF2222"; list.TrueColor = "#33AA33"; list.FalseColor = "#AA3333"; list.NumberColor = "#3333AA"; list.WarningNumberColor = "#DD1111"; list.Lime = "#88DD00"; list.Purple = "#800080";
	return list;
end

local vert;
local buttons;
local labels;
local horz;
local colors = SetTextColors();

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
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
	buttons = {};
	labels = {};
	horz = {};
	permanentLabel1 = UI.CreateHorizontalLayoutGroup(vert);
	permanentLabel2 = UI.CreateHorizontalLayoutGroup(vert);
	UI.CreateLabel(permanentLabel1).SetText("Mod author:\t").SetColor(colors.TextColor);
	UI.CreateLabel(permanentLabel1).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
	UI.CreateLabel(permanentLabel2).SetText("Special thanks to: ").SetColor(colors.TextColor);
	UI.CreateLabel(permanentLabel2).SetText("TBest").SetColor(colors.Purple);
	showMenu();
end

function showMenu()
	resetAll();
	if Mod.Settings.DeployTransferHelper == true then
		createButton(vert, "Add last turns deployment and transfers", "#00ff05", AddOrdersHelper);
		createButton(vert, "Add last turns deployment only", "#00ff05", AddDeployHelper);
		createButton(vert, "Clear Orders", "#0000FF", clearOrdersFunction);
	else
		createLabel(vert, "This game does not use the deploy/transfer helper", colors.FalseColor);
	end
	createButton(vert, "Settings", "#3333FF", showSettings);
	createButton(vert, "Credits", "#88FF00", showCredits);
end

function showCredits()
	resetAll();
	
end

function showSettings()
	resetAll();
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

function getNewHorz()
	table.insert(horz, UI.CreateHorizontalLayoutGroup(vert));
	return horz[#horz];
end

function createLabel(line, text, color)
	table.insert(labels, UI.CreateLabel(line).SetText(text).SetColor(color));
end

function createButton(root, text, color, func)
	table.insert(buttons, UI.CreateButton(root).SetText(text).SetColor(color).SetOnClick(func));
end


function resetAll()
	deleteUI(buttons);
	deleteUI(labels);
	deleteUI(horz);
	horz = {};
	buttons = {};
	labels = {};
end

function deleteUI(list)
	for ID, item in pairs(list) do
		UI.Destroy(item);
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

function AddDeploy()
	print ('running AddDeploy');

	
	if Game.Us.HasCommittedOrders == true then
		UI.Alert("You need to uncommit first");
		return;
	end
	
	local orderTabel = Game.Orders;--get client order list
	if next(orderTabel) ~= nil then --make sure we don't have past orders, since that is alot of extra work
		UI.Alert('Please clear your order list before using this mod.')
		return;
	end
	
	
	local maxDeployBonuses = {}; --array with the bonuses
	for _, bonus in pairs (Game.Map.Bonuses) do
		maxDeployBonuses[bonus.ID] = bonus.Amount --store the bonus value
	end
	
	local newOrder;
	
	for _,order in pairs(LastTurn) do
		if order.PlayerID == Game.Us.ID then
			if order.proxyType == "GameOrderDeploy" then
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
						if (maxDeployBonuses[bonusID] - order.NumArmies >=0) then --deploy full
							maxDeployBonuses[bonusID] = maxDeployBonuses[bonusID] - order.NumArmies
							newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, order.NumArmies, order.DeployOn, false)
							table.insert(orderTabel, newOrder);
						elseif (maxDeployBonuses[bonusID] > 0) then --deploy the max we can
							newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, maxDeployBonuses[bonusID], order.DeployOn, false)
							table.insert(orderTabel, newOrder);
							maxDeployBonuses[bonusID] = 0;
						end
					end
				end
			end
		end
	end
	--update client orders list
	Game.Orders = orderTabel;
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
			if order.proxyType == "GameOrderDeploy" then
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
							newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, order.NumArmies, order.DeployOn, false)
							table.insert(orderTabel, newOrder);
						elseif maxDeployBonuses[bonusID] > 0 then --deploy the max we can
							newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, maxDeployBonuses[bonusID], order.DeployOn, false)
							table.insert(orderTabel, newOrder);
							maxDeployBonuses[bonusID] = 0;
						end
					end
				end
			end
			if (order.proxyType == "GameOrderAttackTransfer") then
				if (Game.Us.ID == standing.Territories[order.From].OwnerPlayerID) then --from us 
					if (Game.Us.ID == standing.Territories[order.To].OwnerPlayerID) then -- to us
							newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To,3, order.ByPercent, order.NumArmies, false)	
						table.insert(orderTabel, newOrder);
					end
				end
			end
		end
	end
	--update client orders list
	Game.Orders = orderTabel;
end;

function AddDeployHelper()
	standing = Game.LatestStanding; --used to make sure we can make the deploy/transfer
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
	Game.GetTurn(turn, function(data) getTurnHelperAdd(data) end)--getTurnHelperAdd(data) end)
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

function getTurnHelperAdd(prevTurn)
	print('got prevTurn');
	LastTurn = prevTurn.Orders;
	AddDeploy();
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