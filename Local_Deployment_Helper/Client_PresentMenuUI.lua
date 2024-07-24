require("UI")

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close, gameRefreshAction)
	Init(rootParent);
	colors = GetColors();
	Game = game; --global variables
	Close = close;
	
	LastTurn = {};   --we get the orders from History later
	Distribution = {};	
	
	setMaxSize(500, 420);
	
	vert = GetRoot();
	vert.SetFlexibleWidth(1);
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
	SetWindow("DummyWindow");
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
			Game.SendGameCustomMessage("Submitting...", {Type = "PickOption", AutoDeploy = autoDeployOption.GetIsChecked(), ShowWindow = showWindowOption.GetIsChecked(), DoNothing = doNothingOption.GetIsChecked()}, function(t) end);
			Close();
		else
			UI.Alert("You can only pick 1 option, not 0, 2 or 3");
		end
	end);
	CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(showMenu);
	CreateEmpty(line).SetFlexibleWidth(0.5);
end

function showCredits()
	DestroyWindow();
	SetWindow("showCredits");
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

	local line = CreateHorz(root).SetFlexibleWidth(1);
	addAttacks = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.AddAttacks);
	CreateLabel(line).SetText("Add attacks").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When checked your attacks from the previous turn will be added if you still control the attacking territory") end);
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	setToPercentage = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.SetToPercentage).SetInteractable(Game.Settings.AllowPercentageAttacks);
	CreateLabel(line).SetText("overwrite all attacks/transfers to percentage orders").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("When checked all your transfers will be overwritten to 100% attacks/transfers. This will allow every army to be transferred, no matter the amount of armies") end);
	
	line = CreateHorz(root).SetFlexibleWidth(1);
	removeZeroTransfers = CreateCheckBox(line).SetText(" ").SetIsChecked(inputs.RemoveZeroTransfers);
	CreateLabel(line).SetText("Remove all orders that transfer / attack with 0 armies").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("Let the mod remove all the transfer / attack orders that will transfer / attack with 0 armies this turn. Useful to clean up your orderlist") end);

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
	
	local maxDeployBonuses = removeDeployedBonuses(Game.Us.Income(0, Game.LatestStanding, false, false).BonusRestrictions);
	local orderTable = Game.Orders;
	local appendDeploys = 0;
	local appendTransfers = 0;
	for i, order in pairs(orderTable) do
		print(i, order.OccursInPhase);
		if order.OccursInPhase ~= nil then
			if appendDeploys == 0 and order.OccursInPhase > WL.TurnPhase.Deploys then
				print(order.proxyType, "appendDeploys: " .. i);
				appendDeploys = i;
			elseif appendTransfers == 0 and order.OccursInPhase > WL.TurnPhase.Attacks then
				print(order.proxyType, "appendTransfers: " .. i);
				appendTransfers = i;
			end
		end
	end
	if appendDeploys == 0 then
		appendDeploys = #orderTable + 1;
	end
	if appendTransfers == 0 then
		appendTransfers = #orderTable + 1;
	end
	appendTransfers = appendTransfers - appendDeploys;
	print(appendDeploys, appendTransfers + appendDeploys, #orderTable);
	local newOrder;
	local lastDeploymentMade = {};

	for _, order in pairs(LastTurn) do
		if order.PlayerID == Game.Us.ID then
			if order.proxyType == "GameOrderDeploy" and inputs.AddDeployments == true then
					--check that we own the territory
				if Game.Us.ID == standing.Territories[order.DeployOn].OwnerPlayerID then
					--check that we have armies to deploy
					local bonusID = getBonus(order.DeployOn);
					--make sure we deploy more then 0
					if bonusID ~= -1 and order.NumArmies > 0 and maxDeployBonuses[bonusID] ~= nil and maxDeployBonuses[bonusID] > 0 then
						if maxDeployBonuses[bonusID] - order.NumArmies >=0 then --deploy full
							newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, order.NumArmies, order.DeployOn, false);
							maxDeployBonuses[bonusID] = maxDeployBonuses[bonusID] - order.NumArmies;
						else --deploy the max we can
							newOrder = WL.GameOrderDeploy.Create(Game.Us.ID, maxDeployBonuses[bonusID], order.DeployOn, false);
							maxDeployBonuses[bonusID] = 0;
						end
						local index = orderExists(newOrder, orderTable);
						if index == 0 then
							table.insert(orderTable, appendDeploys, newOrder);
							appendDeploys = appendDeploys + 1;
						else
							table.insert(orderTable, appendDeploys, WL.GameOrderDeploy.Create(Game.Us.ID, newOrder.NumArmies + orderTable[index].NumArmies, order.DeployOn, false));
							table.remove(orderTable, index);
						end
					end
				end
			end
			if order.proxyType == "GameOrderAttackTransfer" and Game.Us.ID == standing.Territories[order.From].OwnerPlayerID and (inputs.AddAttacks or (inputs.AddTransfers and Game.Us.ID == standing.Territories[order.To].OwnerPlayerID)) and (not inputs.RemoveZeroTransfers or not standing.Territories[order.From].NumArmies.IsEmpty or orderExists(WL.GameOrderDeploy.Create(Game.Us.ID, 1, order.From, false), orderTable) ~= 0) then
				if inputs.SetToPercentage and Game.Settings.AllowPercentageAttacks then
					if order.ByPercent then
						newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To, 3, true, WL.Armies.Create(order.NumArmies.NumArmies, {}), false);
					else
						newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To, 3, true, WL.Armies.Create(100, {}), false);
					end
				else
					newOrder = WL.GameOrderAttackTransfer.Create(Game.Us.ID, order.From, order.To, 3, order.ByPercent, order.NumArmies, false);
				end
				if orderExists(newOrder, orderTable) == 0 then
					print(appendDeploys, appendTransfers, #orderTable);
					table.insert(orderTable, appendDeploys + appendTransfers, newOrder);
					appendTransfers = appendTransfers + 1;
				end
			end
		end
	end

	if inputs.AddDeployments then
		for i, v in pairs(removeDeployedBonuses(copyTable(maxDeployBonuses), orderTable)) do
			if v ~= 0 then
				if inputs.AlwaysDeployInSingleTerrBonuses and #Game.Map.Bonuses[i].Territories == 1  then
					local order = WL.GameOrderDeploy.Create(Game.Us.ID, v, Game.Map.Bonuses[i].Territories[1], false);
					local index = orderExists(order, orderTable);
					if index == 0 then
						table.insert(orderTable, appendDeploys, order);
						appendDeploys = appendDeploys + 1;
					else
						table.insert(orderTable, appendDeploys, WL.GameOrderDeploy.Create(Game.Us.ID, v + orderTable[index].NumArmies, Game.Map.Bonuses[i].Territories[1], false));
						table.remove(orderTable, index);
					end
				elseif inputs.DeployAllArmies then
					local index = getDeploymentInBonus(orderTable, i);
					if index ~= 0 then
						table.insert(orderTable, appendDeploys, WL.GameOrderDeploy.Create(Game.Us.ID, v + orderTable[index].NumArmies, orderTable[index].DeployOn, false));
						table.remove(orderTable, index);
					end
				end
			end
		end
	end

	--update client orders list
	Game.Orders = orderTable;
--	Close();
end;


function AddOrdersHelper(inputs)
	Close();
	standing = Game.LatestStanding;

	if Game.Game.TurnNumber - 2 >= 0 then
		Game.GetTurn(Game.Game.TurnNumber - 2, function(data) LastTurn = data.Orders; AddOrdersConfirmes(inputs); end)
		
	end
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

function orderExists(newOrder, orders)
	if orders == nil then orders = Game.Orders; end
	for i, order in pairs(orders) do
		if order.proxyType == newOrder.proxyType then
			if order.proxyType == "GameOrderAttackTransfer" then
				if order.To == newOrder.To and order.From == newOrder.From then
					return i;
				end
			elseif order.proxyType == "GameOrderDeploy" then
				if order.DeployOn == newOrder.DeployOn then
					return i;
				end
			end
		end
	end
	return 0;
end

function getDeploymentInBonus(orders, bonusID)
	for i, order in pairs(orders) do
		if order.proxyType == "GameOrderDeploy" and valueInTable(Game.Map.Bonuses[bonusID].Territories, order.DeployOn) then
			return i;
		end
	end
	return 0;
end
function valueInTable(t, v)
	for i, v2 in pairs(t) do
		if v2 == v then 
			return true; 
		end
	end
	return false;
end

function removeDeployedBonuses(t, orders)
	if orders == nil then
		orders = Game.Orders;
	end
	for _, order in pairs(orders) do
		if order.proxyType == "GameOrderDeploy" then
			local bonus = getBonus(order.DeployOn);
			if bonus ~= -1 and t[bonus] ~= nil then
				t[bonus] = t[bonus] - order.NumArmies;
			end
		end
	end
	return t;
end

function getBonus(terrID)
	for i, bonus in ipairs(Game.Map.Territories[terrID].PartOfBonuses) do
		if bonusValue(bonus) ~= 0 then
			return bonus;
		end
	end
	return -1;
end

function getUsedInputs(inputs)
	local t = {AddDeployments = addDeployments.GetIsChecked(), AddTransfers = addTransfers.GetIsChecked()}
	if t.AddDeployments then
		t.DeployAllArmies = deployAllArmies.GetIsChecked();
		t.AlwaysDeployInSingleTerrBonuses = deploySingleTerr.GetIsChecked();
	else
		if inputs.AlwaysDeployInSingleTerrBonuses ~= nil then
			t.AlwaysDeployInSingleTerrBonuses = inputs.AlwaysDeployInSingleTerrBonuses;
		else
			t.AlwaysDeployInSingleTerrBonuses = false;
		end
		if inputs.DeployAllArmies ~= nil then
			t.DeployAllArmies = inputs.DeployAllArmies;
		else
			t.DeployAllArmies = false;
		end
	end
	if t.AddTransfers then
		t.AddAttacks = addAttacks.GetIsChecked();
		t.SetToPercentage = setToPercentage.GetIsChecked();
		t.RemoveZeroTransfers = removeZeroTransfers.GetIsChecked();
	else
		if inputs.AddAttacks ~= nil then
			t.AddAttacks = inputs.AddAttacks;
		else
			t.AddAttacks = false;
		end
		if inputs.SetToPercentage ~= nil then
			t.SetToPercentage = inputs.SetToPercentage
		else
			t.SetToPercentage = false;
		end
		if inputs.RemoveZeroTransfers ~= nil then
			t.RemoveZeroTransfers = inputs.RemoveZeroTransfers
		else
			t.RemoveZeroTransfers = false;
		end
	end
	return t;
end

function copyTable(orig)
	local copy = {};
	for i, v in pairs(orig) do
		if type(v) == type({}) then
			copy[i] = copyTable(v);
		else
			copy[i] = v;
		end
	end
	return copy;
end
function getInputs()
	if Mod.PlayerGameData.SavedInputs == nil then
		return {AddDeployments = false, AlwaysDeployInSingleTerrBonuses = false, DeployAllArmies = false; AddTransfers = false, SetToPercentage = false, AddAttacks = false, RemoveZeroTransfers = false};
	else
		return Mod.PlayerGameData.SavedInputs;
	end
end