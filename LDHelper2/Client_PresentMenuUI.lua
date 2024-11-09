require("UI");
require("Timer");

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close, gameRefreshAction)
	if not UI.IsDestroyed(vert) and Close ~= nil then
		Close();
	end
	Init(rootParent);
	-- Timer.Init(WL);
	colors = GetColors();
	Game = game; --global variables
	Close = close;


	
	LastTurn = {};   --we get the orders from History later
	Distribution = {};	
	
	setMaxSize(500, 420);
	
	vert = GetRoot();
	vert.SetFlexibleWidth(1);
	
	if (not game.Settings.LocalDeployments) then
		return CreateLabel(vert).SetText("This mod only works in Local Deployment games. This isn't a Local Deployment game").SetColor(colors.TextColor);
	elseif (game.Us == nil or game.Us.State ~= WL.GamePlayerState.Playing) then
		return CreateLabel(vert).SetText("You cannot do anything since you're not in the game.").SetColor(colors.TextColor);
	end

	if game.Us == nil then return; end
	if game.Us.IsAIOrHumanTurnedIntoAI then return; end

	if gameRefreshAction == nil then
		showMenu();
	else
		if gameRefreshAction == "SetAction" then
			setAction();
		elseif gameRefreshAction == "AutoDeploy" then
			AddOrdersHelper(getInputs());
		elseif gameRefreshAction == "ShowWindow" then
			showHelperMenu();
		elseif gameRefreshAction == "SetDefaultOptions" then
			showHelperMenu(true);
		else
			return CreateLabel(vert).SetText("Something went wrong: Refresh action not recognized").SetColor(colors["Orange Red"])
		end
	end
end

function showMenu()
	DestroyWindow();
	SetWindow("showMenu");
	local line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateButton(line).SetText("Go to deploy/transfer helper").SetColor(colors.Green).SetOnClick(showHelperMenu);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function()
		UI.Alert("Here you can let the mod automatically add deploy / transfer orders");
	end)
	if Game.Game.TurnNumber == 1 then
		line = CreateHorz(vert).SetFlexibleWidth(1);
		CreateButton(line).SetText("Deploy in all bonuses of size 1").SetColor(colors.Purple).SetOnClick(addDeploysTurnOne);
		CreateEmpty(line).SetFlexibleWidth(1);
		CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function()
			UI.Alert("This automatically deploys in all bonuses that consist out of only 1 territory");
		end)
	end
	line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateButton(line).SetText("Automatic order creation").SetColor(colors.Yellow).SetOnClick(setAction);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function()
		UI.Alert("Set what the mod will do when you open the game after a turn has advanced");
	end)
	line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateButton(line).SetText("Set default settings").SetColor(colors.Lime).SetOnClick(function() showHelperMenu(true) end)
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function()
		UI.Alert("Set the default options when adding your past deploy/transfer order");
	end)
	CreateButton(vert).SetText("Clear Orders").SetColor(colors.Blue).SetOnClick(clearOrdersFunction);
	CreateButton(vert).SetText("Credits").SetColor(colors.Orange).SetOnClick(showCredits);
end

function setAction()
	DestroyWindow();
	SetWindow("setAction");

	CreateLabel(vert).SetText("Below you can set what action this mod should take every new turn. If you don't want this mod do stuff automatically, choose the last option").SetColor(colors.TextColor);
	local currentAction = Mod.PlayerGameData.NewTurnAction or "None";

	local line = CreateHorz(vert).SetFlexibleWidth(1);
	autoDeployOption = CreateCheckBox(line).SetText(" ").SetIsChecked(currentAction == "AutoDeploy").SetOnValueChanged(function() if autoDeployOption.GetIsChecked() then showWindowOption.SetIsChecked(false); doNothingOption.SetIsChecked(false); end end);
	CreateLabel(line).SetText("Automatically re-add orders").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("This option will let the mod re-add all your deployment and transfer / attack orders from last turn. You do need to set what options the mod should use and which not"); end);
	
	line = CreateHorz(vert).SetFlexibleWidth(1);
	showWindowOption = CreateCheckBox(line).SetText(" ").SetIsChecked(currentAction == "ShowWindow").SetOnValueChanged(function() if showWindowOption.GetIsChecked() then doNothingOption.SetIsChecked(false); autoDeployOption.SetIsChecked(false); end end);
	CreateLabel(line).SetText("Automatically open LD Helper").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("This option will open the Local Deployment Helper window everytime you enter the game again after a new turn has advanced. This allows you to determine what orders you want to (re-)add every time"); end);
	
	line = CreateHorz(vert).SetFlexibleWidth(1);
	doNothingOption = CreateCheckBox(line).SetText(" ").SetIsChecked(currentAction == "DoNothing").SetOnValueChanged(function() if doNothingOption.GetIsChecked() then showWindowOption.SetIsChecked(false); autoDeployOption.SetIsChecked(false); end end);
	CreateLabel(line).SetText("Do nothing automatically").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("If you do not want to use this mod or want to choose yourself what you do with the mod, choose this option"); end);
	
	line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateButton(line).SetText("Submit").SetColor(colors.Green).SetOnClick(function() 
		if (autoDeployOption.GetIsChecked() and not showWindowOption.GetIsChecked() and not doNothingOption.GetIsChecked()) or (not autoDeployOption.GetIsChecked() and showWindowOption.GetIsChecked() and not doNothingOption.GetIsChecked()) or (not autoDeployOption.GetIsChecked() and not showWindowOption.GetIsChecked() and doNothingOption.GetIsChecked()) then
			Close();
			Game.SendGameCustomMessage("Submitting...", {Type = "PickOption", AutoDeploy = autoDeployOption.GetIsChecked(), ShowWindow = showWindowOption.GetIsChecked(), DoNothing = doNothingOption.GetIsChecked()}, function(t) end);
		else
			UI.Alert("You can only pick 1 option");
		end
	end);
	CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(showMenu);
	CreateEmpty(line).SetFlexibleWidth(0.5);
end

function showCredits()
	DestroyWindow();
	SetWindow("showCredits");
	permanentLabel1 = CreateHorz(vert).SetFlexibleWidth(1);
	permanentLabel2 = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(permanentLabel1).SetFlexibleWidth(0.5);
	CreateEmpty(permanentLabel2).SetFlexibleWidth(0.5);
	CreateLabel(permanentLabel1).SetText("Mod author:\t").SetColor(colors.TextColor);
	CreateLabel(permanentLabel1).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
	CreateLabel(permanentLabel2).SetText("Special thanks to:\t").SetColor(colors.TextColor);
	CreateLabel(permanentLabel2).SetText("TBest").SetColor(colors.Purple);
	CreateEmpty(permanentLabel1).SetFlexibleWidth(0.5);
	CreateEmpty(permanentLabel2).SetFlexibleWidth(0.5);
	CreateEmpty(vert).SetPreferredHeight(5);
	
	CreateLabel(vert).SetText("Testers:").SetColor(colors.TextColor);
	local line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateLabel(line).SetText("JK_3").SetColor(colors.Green);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateLabel(line).SetText("krinid").SetColor(colors["Tyrian Purple"]);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateLabel(line).SetText("El Teoremas").SetColor(colors["Dark Magenta"]);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateLabel(line).SetText("Zazzlegut").SetColor(colors.Green);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateEmpty(vert).SetPreferredHeight(5);
	CreateLabel(vert).SetText("And of course thanks to all players who have helped me along the way, suggesting features or pointing out some bugs")
	CreateButton(vert).SetText("Return").SetColor(colors.Orange).SetOnClick(showMenu);
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
			table.insert(orders, WL.GameOrderDeploy.Create(Game.Us.ID, worth, Game.Map.Bonuses[bonusID].Territories[1], false));
		end
	end
	
	Game.Orders = orders;
end

function showHelperMenu(setToDefaultMode)
	setToDefaultMode = setToDefaultMode or false;
	if Game.Game.TurnNumber < 2 and not setToDefaultMode then
		UI.Alert("You cannot use the helper function in the distribution phase or in turn 1");
		Close();
		return;
	end
	DestroyWindow();
	SetWindow("showHelperMenu");
	if setToDefaultMode then
		CreateLabel(vert).SetText("Choose the default options you want. If you have set the mod to automatically re-add the orders back, the default options will always be used.\n\nYou can always change the options at any time in the mod menu")
	end
	local inputs = getInputs();
	local line = CreateHorz(vert).SetFlexibleWidth(1);
	addDeployments = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.AddDeployments);
	CreateLabel(line).SetText("Add deployments").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When checked your deployments from the previous turn will be added to your orderlist") end)
	local deployVert = CreateVert(vert).SetFlexibleWidth(1);
	addDeployments.SetOnValueChanged(function() if addDeployments.GetIsChecked() then extraDeployOptions(deployVert, inputs); else DestroyWindow("extraDeployOptions"); end end);
	if inputs.AddDeployments then extraDeployOptions(deployVert, inputs); end
	
	line = CreateHorz(vert).SetFlexibleWidth(1);
	addTransfers = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.AddTransfers);
	CreateLabel(line).SetText("Add transfers").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When checked your transfers from the previous turn will be added to your orderlist") end)
	local transferVert = CreateVert(vert).SetFlexibleWidth(1).SetPreferredHeight(0);
	addTransfers.SetOnValueChanged(function() if addTransfers.GetIsChecked() then extraTransferOptions(transferVert, inputs); else DestroyWindow("extraTransferOptions"); end end);
	if inputs.AddTransfers then extraTransferOptions(transferVert, inputs); end

	CreateEmpty(vert).SetPreferredHeight(5);
	if setToDefaultMode then
		local line = CreateHorz(vert).SetFlexibleWidth(1);
		CreateEmpty(line).SetFlexibleWidth(0.5);
		CreateButton(line).SetText("Set Default").SetColor(colors.Green).SetOnClick(function() local data = getUsedInputs(inputs); Game.SendGameCustomMessage("Saving inputs...", {Type = "SaveInputs", Data = data}, function(t) end); Close(); end)
		CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(showMenu);
		CreateEmpty(line).SetFlexibleWidth(0.5);
	else
		addOrdersButton = CreateButton(vert).SetText("Add orders").SetColor(colors.Green).SetOnClick(function() local data = getUsedInputs(inputs); AddOrdersHelper(data); end);
	end
end

function extraDeployOptions(vert, inputs)
	local win = "extraDeployOptions";
	local currentWindow = GetCurrentWindow();
	DestroyWindow(win);
	AddSubWindow(currentWindow, win)
	SetWindow(win);

	local rootLine = CreateHorz(vert);
	CreateVert(rootLine).SetPreferredWidth(25);
	local root = CreateVert(rootLine).SetFlexibleWidth(1);
	
	local line = CreateHorz(root).SetFlexibleWidth(1);
	deploySingleTerr = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.AlwaysDeployInSingleTerrBonuses);
	CreateLabel(line).SetText("Deploy every army in bonuses that have 1 territory").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("Let the mod deploy in every bonus that only has 1 territory. If you hold such a bonus for the first time, it will do the deployment for you") end);
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	deployAllArmies = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.DeployAllArmies);
	CreateLabel(line).SetText("Fully deploy in every bonus with a deployment").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("Let the mod deploy in every bonus were you still need to deploy some armies. The mod will add the left over armies to the last deployment made in that bonus") end);

	SetWindow(currentWindow);
end


function extraTransferOptions(vert, inputs)
	local win = "extraTransferOptions";
	local currentWindow = GetCurrentWindow();
	DestroyWindow(win);
	AddSubWindow(currentWindow, win)
	SetWindow(win);

	local rootLine = CreateHorz(vert);
	CreateVert(rootLine).SetPreferredWidth(25);
	local root = CreateVert(rootLine).SetFlexibleWidth(1);

	line = CreateHorz(root).SetFlexibleWidth(1);
	setToPercentage = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.SetToPercentage).SetInteractable(Game.Settings.AllowPercentageAttacks);
	CreateLabel(line).SetText("Make all transfers percentage orders").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When checked all your transfers will be overwritten to 100% transfers. This will allow every army to be transferred, no matter the amount of armies") end);
	
	local line = CreateHorz(root).SetFlexibleWidth(1);
	moveUnmovedArmies = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.MoveUnmovedArmies);
	CreateLabel(line).SetText("Add unmoved armies to first transfer").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When checked, the mod will check whether territories have armies that don't have an order to transfer yet. If there is at least 1 transfer order, the armies will be added to that transfer order") end);
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	removeZeroTransfers = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.RemoveZeroTransfers);
	CreateLabel(line).SetText("Remove all orders that transfer 0 armies").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("Let the mod remove all the transfer orders that will transfer 0 armies this turn. Useful to clean up your orderlist") end);

	line = CreateHorz(root).SetFlexibleWidth(1);
	moveSpecialUnits = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.MoveSpecialUnits);
	CreateLabel(line).SetText("Move special units").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When checked, the mod will include special units to move along with the normal armies. Commanders are never moved by this mod") end);

	SetWindow(currentWindow);
end

function clearOrdersFunction()
	if Game.Us.HasCommittedOrders then
		return UI.Alert("You need to uncommit first");
	end
	local orderTable = Game.Orders;
	
	if next(orderTable) ~= nil then
		orderTable = {}
		Game.Orders = orderTable
	end
end;

function AddOrdersConfirmes(inputs)	
	if Game.Us.HasCommittedOrders == true then
		UI.Alert("You need to uncommit first");
		return;
	end

	print("Num orders last turn: " .. #LastTurn);

	local orders = Game.Orders;
	local territories = Game.LatestStanding.Territories;
	local orderListIndex, endOfList;
	local deployMap = nil;
	local pastOrderListIndex;
	
	-- Timer.Start("Total");
	if inputs.AddDeployments then
		-- Timer.Start("Init");
		local territoryToBonusMap = Mod.PublicGameData.TerritoryToBonusMap;
		orderListIndex, endOfList = getFirstOrderOfPhase(orders, WL.TurnPhase.Deploys);
		local bonusMap = createBonusMap(Game.LatestStanding);
		local previousBonusMap = createBonusMap(LastStanding);
		deployMap = {};
		-- Timer.Stop("Init");
		
		-- Update bonusMap with deploy orders already in the order list
		-- Timer.Start("Current orders");
		if not endOfList then
			local order = orders[orderListIndex];
			while orderIsBeforePhase(order, WL.TurnPhase.Deploys + 1) do
				if order.proxyType == "GameOrderDeploy" then
					local terrID = order.DeployOn;
					deployMap[terrID] = order.NumArmies;
					local bonusID = territoryToBonusMap[terrID];
					if bonusID ~= nil and bonusMap[bonusID] ~= nil then
						bonusMap[bonusID] = {
							NumArmies = math.max(0, bonusMap[bonusID].NumArmies - order.NumArmies),
							OrderIndex = orderListIndex;
						}
					end
					orderListIndex = orderListIndex + 1;
					order = orders[orderListIndex];
				end
			end
		end
		-- Timer.Stop("Current orders");
		
		-- Timer.Start("Past orders");
		pastOrderListIndex = getFirstOrderOfPhase(LastTurn, WL.TurnPhase.Deploys);
		local order = LastTurn[pastOrderListIndex];
		while orderIsBeforePhase(order, WL.TurnPhase.Deploys + 1) do
			if order.proxyType == "GameOrderDeploy" then
				local terrID = order.DeployOn;
				local bonusID = territoryToBonusMap[terrID];
				if deployMap[terrID] == nil and territories[terrID].OwnerPlayerID == Game.Us.ID and previousBonusMap[bonusID] ~= nil and bonusMap[bonusID] ~= nil and bonusMap[bonusID].NumArmies > 0 then
					table.insert(orders, orderListIndex, WL.GameOrderDeploy.Create(Game.Us.ID, math.min(bonusMap[bonusID].NumArmies, order.NumArmies), terrID, false));
					deployMap[terrID] = math.min(bonusMap[bonusID].NumArmies, order.NumArmies);
					bonusMap[bonusID] = {
						NumArmies = math.max(0, bonusMap[bonusID].NumArmies - order.NumArmies),
						OrderIndex = orderListIndex;
					}
					orderListIndex = orderListIndex + 1;
				end
			end
			pastOrderListIndex = pastOrderListIndex + 1;
			order = LastTurn[pastOrderListIndex];
		end
		-- Timer.Stop("Past orders");
		
		-- Timer.Start("Deploy last armies")
		if inputs.DeployAllArmies or inputs.AlwaysDeployInSingleTerrBonuses then
			for bonusID, bonus in pairs(bonusMap) do
				if bonus.NumArmies > 0 then
					if bonus.OrderIndex ~= nil and inputs.DeployAllArmies then
						local old = orders[bonus.OrderIndex];
						table.remove(orders, bonus.OrderIndex);
						table.insert(orders, bonus.OrderIndex, WL.GameOrderDeploy.Create(Game.Us.ID, old.NumArmies + bonus.NumArmies, old.DeployOn, false));
						deployMap[old.DeployOn] = deployMap[old.DeployOn] + bonus.NumArmies;
					elseif inputs.AlwaysDeployInSingleTerrBonuses and isSingleTerrBonus(Game.Map.Bonuses[bonusID]) then
						if bonus.OrderIndex == nil then
							local terrID = getFirstTerritoryOfBonus(Game.Map.Bonuses[bonusID]);
							table.insert(orders, orderListIndex, WL.GameOrderDeploy.Create(Game.Us.ID, bonusMap[bonusID].NumArmies, terrID, false));
							deployMap[terrID] = bonusMap[bonusID].NumArmies;
							orderListIndex = orderListIndex + 1;
						else
							local old = orders[bonus.OrderIndex];
							table.remove(orders, bonus.OrderIndex);
							table.insert(orders, bonus.OrderIndex, WL.GameOrderDeploy.Create(Game.Us.ID, old.NumArmies + bonus.NumArmies, old.DeployOn, false));
							deployMap[old.DeployOn] = deployMap[old.DeployOn] + bonus.NumArmies;
						end
					end
				end
			end
		end
		-- Timer.Stop("Deploy last armies");
	end
	
	
	if inputs.AddTransfers then
		-- Timer.Start("Init armies map");
		if deployMap == nil then
			deployMap = createDeployMap(orders);
		end
		local armiesMap = createArmiesMap(Game.LatestStanding.Territories, deployMap, inputs.MoveSpecialUnits);
		-- Timer.Stop("Init armies map");
		local transferMap = {};
		
		orderListIndex, endOfList = getFirstOrderOfPhase(orders, WL.TurnPhase.Attacks, orderListIndex);
		
		-- Timer.Start("Current orders");
		if not endOfList then
			local order = orders[orderListIndex];
			while orderIsBeforePhase(order, WL.TurnPhase.Attacks + 1) do
				if order.proxyType == "GameOrderAttackTransfer" then
					transferMap[order.From] = transferMap[order.From] or {};
					table.insert(transferMap[order.From], { To = order.To, OrderIndex = orderListIndex });
					-- remove 0 army transfers
					if inputs.RemoveZeroTransfers and armiesMap[order.From].IsEmpty then
						table.remove(orders, orderListIndex);
						orderListIndex = orderListIndex - 1;
					else
						armiesMap[order.From] = armiesMap[order.From].Subtract(order.NumArmies);
					end
				end
				orderListIndex = orderListIndex + 1;
				order = orders[orderListIndex];
			end
		end
		-- Timer.Stop("Current orders");
		
		-- Timer.Start("Past transfer");
		pastOrderListIndex = getFirstOrderOfPhase(LastTurn, WL.TurnPhase.Attacks, pastOrderListIndex or 1);
		local order = LastTurn[pastOrderListIndex];
		while orderIsBeforePhase(order, WL.TurnPhase.Attacks + 1) do
			if order.proxyType == "GameOrderAttackTransfer" and order.PlayerID == Game.Us.ID then
				local from = order.From;
				local to = order.To;
				if territories[from].OwnerPlayerID == Game.Us.ID and isTeamMate(Game.Game.Players[territories[to].OwnerPlayerID]) and not order.Result.IsAttack and (transferMap[from] == nil or not transferInList(transferMap[from], to)) then
					if not inputs.RemoveZeroTransfers or not armiesMap[from].IsEmpty then
						local armies;
						if not order.ByPercent and not inputs.SetToPercentage then
							local n = 0;
							if order.NumArmies.NumArmies > armiesMap[from].NumArmies then
								n = order.NumArmies.NumArmies - armiesMap[from].NumArmies;
							end
							armies = order.NumArmies.Subtract(WL.Armies.Create(n, order.NumArmies.SpecialUnits or {}));
						elseif order.ByPercent then
							armies = order.NumArmies.Subtract(WL.Armies.Create(0, order.NumArmies.SpecialUnits or {}));
						else
							armies = WL.Armies.Create(100);
						end
						local new = WL.GameOrderAttackTransfer.Create(Game.Us.ID, from, to, order.AttackTransfer, inputs.SetToPercentage or order.ByPercent, armies, order.AttackTeammates);
						table.insert(orders, new);
						transferMap[from] = transferMap[from] or {};
						table.insert(transferMap[from], { To = to, OrderIndex = orderListIndex });
						orderListIndex = orderListIndex + 1;
						if new.ByPercent then
							armiesMap[from] = armiesMap[from].Subtract(WL.Armies.Create(round(armiesMap[from].NumArmies * (new.NumArmies.NumArmies / 100))));
						else
							armiesMap[from] = armiesMap[from].Subtract(armies);
						end
					end
				end
			end
			
			pastOrderListIndex = pastOrderListIndex + 1;
			order = LastTurn[pastOrderListIndex];
		end
		-- Timer.Stop("Past transfer");
		
		
		if inputs.MoveUnmovedArmies or inputs.MoveSpecialUnits then
			-- Timer.Start("Add forgotten units")
			for terrID, armies in pairs(armiesMap) do
				if transferMap[terrID] ~= nil then
					local newArmies = nil;
					local old;
					local index;
					for i, _ in ipairs(transferMap[terrID]) do
						old = orders[transferMap[terrID][i].OrderIndex];
						if not old.ByPercent or old.NumArmies.NumArmies >= 100 then
							index = i;
							break;
						end
					end
					if inputs.MoveUnmovedArmies and inputs.MoveSpecialUnits and not armies.IsEmpty then
						newArmies = old.NumArmies.Add(armies);
					elseif inputs.MoveUnmovedArmies and armies.NumArmies > 0 then
						newArmies = old.NumArmies.Add(WL.Armies.Create(armies.NumArmies));
					elseif inputs.MoveSpecialUnits and #armies.SpecialUnits > 0 then
						newArmies = old.NumArmies.Add(WL.Armies.Create(0, armies.SpecialUnits));
					end
					if newArmies ~= nil then
						if old.ByPercent and inputs.MoveUnmovedArmies then
							newArmies = WL.Armies.Create(100, newArmies.SpecialUnits);
						end
						table.remove(orders, transferMap[terrID][index].OrderIndex);
						table.insert(orders, transferMap[terrID][index].OrderIndex, WL.GameOrderAttackTransfer.Create(Game.Us.ID, terrID, transferMap[terrID][index].To, old.AttackTransfer, old.ByPercent, newArmies, old.AttackTeammates));
					end
				end
			end
			-- Timer.Stop("Add forgotten units")
		end
		
	end
	Game.Orders = copyTable(orders);
	-- Timer.Stop("Total");

end;

function getFirstOrderOfPhase(orders, phase, index)
	index = index or 1;
	while orderIsBeforePhase(orders[index], phase) do
		index = index + 1;
	end
	return index, #orders < index;
end

function orderIsBeforePhase(order, phase)
	return order ~= nil and (order.OccursInPhase == nil or order.OccursInPhase < phase); 
end

function createBonusMap(standing)
	local t = {}
	for i, v in pairs(Game.Us.Income(0, standing, false, false).BonusRestrictions) do
		t[i] = { NumArmies = v };
	end
	return t;
end

function createArmiesMap(territories, extraArmies, includeSpecialUnits)
	local t = {};
	for terrID, terr in pairs(territories) do
		if terr.OwnerPlayerID == Game.Us.ID then
			t[terrID] = terr.NumArmies.Add(WL.Armies.Create(extraArmies[terrID] or 0)).Subtract(WL.Armies.Create(0, filterCommanders(filterCommanders(terr.NumArmies.SpecialUnits))));
			if not includeSpecialUnits then
				t[terrID] = t[terrID].Subtract(WL.Armies.Create(0, t[terrID].SpecialUnits));
			end
		end
	end
	return t;
end

function filterCommanders(sps)
	local t = {};
	for _, sp in pairs(sps) do
		if sp.proxyType == "Commander" then
			table.insert(t, sp);
		end 
	end
	return t;
end

function createDeployMap(orders)
	local t = {};
	local index = getFirstOrderOfPhase(orders, WL.TurnPhase.Deploys);
	local order = orders[index];
	while orderIsBeforePhase(order, WL.TurnPhase.Deploys + 1) do
		if order.proxyType == "GameOrderDeploy" then
			t[order.DeployOn] = order.NumArmies;
		end
		index = index + 1;
		order = orders[index];
	end
	return t;
end

function isSingleTerrBonus(bonus)
	local c = 0;
	for _, _ in pairs(bonus.Territories) do
		c = c + 1;
		if c > 1 then return false; end
	end
	return true;
end

function getFirstTerritoryOfBonus(bonus)
	for _, terr in pairs(bonus.Territories) do
		return terr;
	end
end

function transferInList(t, v)
	for _, v2 in pairs(t) do
		if v2.To == v then
			return true;
		end
	end
	return false;
end

function round(n, ndec)
	ndec = ndec or 0;
	dec = 10 ^ ndec;
	return math.floor(n * dec + 0.5) / dec;
end

function copyTable(t)
	local r = {};
	for i, v in pairs(t) do
		r[i] = v;
	end
	return r;
end

function isTeamMate(p)
	return p.ID == Game.Us.ID or (p.Team ~= -1 and p.Team == Game.Us.Team);
end

function AddOrdersHelper(inputs)
	Close();
	standing = Game.LatestStanding;

	if Game.Game.TurnNumber - 2 >= 0 then
		Game.GetTurn(Game.Game.TurnNumber - 2, function(data) LastTurn = data.Orders; end);
		Game.GetStanding(Game.Game.TurnNumber - 2, 0, function(data) LastStanding = data; AddOrdersConfirmes(inputs); end);		
	end
end

function getUsedInputs(inputs)
	local t = {AddDeployments = addDeployments.GetIsChecked(), AddTransfers = addTransfers.GetIsChecked()}
	if t.AddDeployments then
		t.DeployAllArmies = deployAllArmies.GetIsChecked();
		t.AlwaysDeployInSingleTerrBonuses = deploySingleTerr.GetIsChecked();
	else
		t.AlwaysDeployInSingleTerrBonuses = inputs.AlwaysDeployInSingleTerrBonuses or false;
		t.DeployAllArmies = inputs.DeployAllArmies or false;
	end
	if t.AddTransfers then
		t.MoveUnmovedArmies = moveUnmovedArmies.GetIsChecked();
		t.SetToPercentage = setToPercentage.GetIsChecked();
		t.RemoveZeroTransfers = removeZeroTransfers.GetIsChecked();
		t.MoveSpecialUnits = moveSpecialUnits.GetIsChecked();
	else
		t.SetToPercentage = inputs.SetToPercentage or false;
		t.RemoveZeroTransfers = inputs.RemoveZeroTransfers or false;
	end
	return t;
end

function getInputs()
	if Mod.PlayerGameData.SavedInputs == nil then
		return {AddDeployments = false, AlwaysDeployInSingleTerrBonuses = false, DeployAllArmies = false; AddTransfers = false, SetToPercentage = false, RemoveZeroTransfers = false, MoveUnmovedArmies = false, MoveSpecialUnits = false };
	else
		return Mod.PlayerGameData.SavedInputs;
	end
end