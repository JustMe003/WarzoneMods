require("UI");
require("Timer");

local payload = "[LDH_V3]";

function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close, gameRefreshAction)
	if not UI.IsDestroyed(vert) and Close ~= nil then
		Close();
	end
	Init(rootParent);
	Timer.Init(WL);
	colors = GetColors();
	Game = game; --global variables
	Close = close;
	
	LastTurn = {};   --we get the orders from History later
	Distribution = {};	
	
	setMaxSize(500, 530);
	
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
		if game.Game.TurnNumber == 1 then
			showTurnOneMenu();
		else
			showHelperMenu();
		end
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

function showTurnOneMenu()
	DestroyWindow();
	SetWindow("showTurnOneMenu");

	CreateLabel(CreateHorz(vert).SetCenter(true).SetFlexibleWidth(1)).SetText("Welcome to the Local Deployment Helper mod!").SetColor(colors.Lime);

	CreateEmpty(vert).SetPreferredHeight(10);

	CreateLabel(vert).SetText("This mod will add back your orders from the previous turn. Since at this moment there is no previous turn, the mod cannot add your past orders just yet. However, you can use this mod to automatically deploy all the necessary armies in every bonus with only 1 territory.").SetColor(colors.TextColor);
	CreateButton(CreateHorz(vert).SetFlexibleWidth(1).SetCenter(true)).SetText("Deploy").SetColor(colors.Green).SetOnClick(addDeploysTurnOne);
end

function showMenu()
	DestroyWindow();
	SetWindow("showMenu");

	CreateButton(CreateHorz(vert).SetCenter(true).SetFlexibleWidth(1)).SetText("Return").SetColor(colors.Orange).SetOnClick(showHelperMenu);
	
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
	CreateButton(vert).SetText("Credits").SetColor(colors.Orange).SetOnClick(showCredits);

	CreateButton(vert).SetText("Changelog").SetColor(colors.Blue).SetOnClick(showChangeLog);

	line = CreateHorizontalLayoutGroup(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateLabel(line).SetText("Version: ").SetColor("#777777");
	CreateLabel(line).SetText(Mod.PublicGameData.ModVersion or "2.0");
end

function setAction()
	DestroyWindow();
	SetWindow("setAction");

	CreateLabel(vert).SetText("Welcome to the Local Deployment Helper mod! You can use this mod to copy your deployment + transfer orders back from previous turn, deploy your armies, and more to ease the process of creating your orders. The mod can do this completely on its own, or can open a dialog like this for you to pick whatever option you want, or do nothing at all. For more information, check the [?] of the option you are interested in.").SetColor(colors.TextColor);
	local currentAction = Mod.PlayerGameData.NewTurnAction or "DoNothing";

	local line = CreateHorz(vert).SetFlexibleWidth(1);
	autoDeployOption = CreateCheckBox(line).SetText(" ").SetIsChecked(currentAction == "AutoDeploy").SetOnValueChanged(function() if autoDeployOption.GetIsChecked() then showWindowOption.SetIsChecked(false); doNothingOption.SetIsChecked(false); end end);
	CreateLabel(line).SetText("Automatically re-add orders").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("This option will let the mod re-add all your deployment and transfer orders from last turn. When selected, you need to configure the mod what it will do. You can always change the behaviour of the mod in the mod menu"); end);
	
	line = CreateHorz(vert).SetFlexibleWidth(1);
	showWindowOption = CreateCheckBox(line).SetText(" ").SetIsChecked(currentAction == "ShowWindow").SetOnValueChanged(function() if showWindowOption.GetIsChecked() then doNothingOption.SetIsChecked(false); autoDeployOption.SetIsChecked(false); end end);
	CreateLabel(line).SetText("Automatically open LD Helper").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("This option will open the Local Deployment Helper dialog everytime you enter the game again after a new turn has advanced. This allows you to determine what orders you want to (re-)add every time.You can always change the behaviour of the mod in the mod menu"); end);
	
	line = CreateHorz(vert).SetFlexibleWidth(1);
	doNothingOption = CreateCheckBox(line).SetText(" ").SetIsChecked(currentAction == "DoNothing").SetOnValueChanged(function() if doNothingOption.GetIsChecked() then showWindowOption.SetIsChecked(false); autoDeployOption.SetIsChecked(false); end end);
	CreateLabel(line).SetText("Do nothing automatically").SetColor(colors.TextColor);
	CreateEmpty(line).SetFlexibleWidth(1);
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() UI.Alert("If you do not want to use this mod or want to choose yourself what you do with the mod, choose this option. You can always change the behaviour of the mod in the mod menu"); end);
	
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
	line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateLabel(line).SetText("Murk").SetColor(colors["Dark Magenta"]);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateLabel(line).SetText("Rex Imperator").SetColor(colors["Electric Purple"]);
	CreateEmpty(line).SetFlexibleWidth(0.33);
	CreateEmpty(vert).SetPreferredHeight(5);
	line = CreateHorz(vert).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateLabel(line).SetText("Im").SetColor(colors.Ivory);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateEmpty(vert).SetPreferredHeight(5);
	CreateLabel(vert).SetText("And of course thanks to all players who have helped me along the way, suggesting features or pointing out some bugs")
	CreateButton(vert).SetText("Return").SetColor(colors.Orange).SetOnClick(showMenu);
end

function showChangeLog()
	DestroyWindow();
	SetWindow("ChangeLog");
	
	CreateButton(vert).SetText("Return").SetColor(colors.Orange).SetOnClick(showMenu);
	CreateEmpty(vert).SetPreferredHeight(10);
	
	CreateLabel(vert).SetText("Welcome to the new version of the Local Deployment Helper. Although there is not much new to see at first glance, this mod has gotten a complete rework behind the scenes. This version contains some bug fixes left in the previous implementation, and generally improved the speed at which the mod needs to run. In addition, some features were removed and some added, such as compatibility for special units. You can read more about them in the full changelog below").SetColor(colors.TextColor);
	CreateEmpty(vert).SetPreferredHeight(5);
	
	CreateLabel(vert).SetText("Changelog of version 3.0:").SetColor(colors.TextColor);
	local line = CreateHorizontalLayoutGroup(vert);
	CreateVert(line).SetPreferredWidth(10);
	local vert2 = CreateVert(line);
	
	CreateLabel(vert2).SetText("- Fixed the default action dialog popping up multiple times").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- Removed [Clear Orders] button since there is already a built-in feature for this").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- Moved creator and thanks message to credits page, instead of every page").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- \"Do Nothing\" is now the default action. This prevents the action dialog window from popping up in later turns").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- Whenever you just captured a bonus last turn, the mod will not add back the deployments in that bonus").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- Removed the \"Add attacks\" option in transfers").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- Added \"Add unmoved armies to first transfer\" option for games without the option \"Attack by percentage\"").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- The \"remove all 0 armies orders\" now only works on orders that are added from the previous turn").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- Added the option to move special units. Note that Commanders will never be moved by this mod").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- Renamed the 0 armies transfer removal option").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- Added [Cancel] button to the Deploy/Transfer Helper page").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- Updated credits page").SetColor(colors.TextColor);
	CreateLabel(vert2).SetText("- Added version to the main page").SetColor(colors.TextColor);
end

function addDeploysTurnOne()
	local orders = Game.Orders;
	if #orders > 0 then
		UI.Alert("Remove all orders from your order list to deploy in every 1-territory bonus");
		Close();
		return;
	end

	local bonuses = Game.Map.Bonuses;
	for bonusID, worth in pairs(Game.Us.Income(0, Game.LatestStanding, false, false).BonusRestrictions) do
		if #bonuses[bonusID].Territories == 1 then
			table.insert(orders, WL.GameOrderDeploy.Create(Game.Us.ID, worth, Game.Map.Bonuses[bonusID].Territories[1], false));
		end
	end
	
	Game.Orders = orders;
	Close();
end

function showHelperMenu(setToDefaultMode)
	setToDefaultMode = setToDefaultMode or false;
	if Game.Game.TurnNumber < 2 and not setToDefaultMode then
		UI.Alert("You cannot use the mod in the distribution turn");
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
	line = CreateHorz(vert).SetFlexibleWidth(1).SetCenter(true);
	if setToDefaultMode then
		CreateButton(line).SetText("Set Default").SetColor(colors.Green).SetOnClick(function() local data = getUsedInputs(inputs); Game.SendGameCustomMessage("Saving inputs...", {Type = "SaveInputs", Data = data}, function(t) end); Close(); end)
		CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(showMenu);
	else
		addOrdersButton = CreateButton(line).SetText("Add orders").SetColor(colors.Green).SetOnClick(function() local data = getUsedInputs(inputs); AddOrdersHelper(data); end);
		addOrdersButton = CreateButton(line).SetText("Settings").SetColor(colors.Red).SetOnClick(showMenu);
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
	CreateButton(line).SetText("?").SetColor(colors.Blue).SetOnClick(function() 
		if Game.Settings.AllowPercentageAttacks then
			UI.Alert("When checked all your transfers will be overwritten to 100% transfers. This will allow every army to be transferred, no matter the amount of armies");
		else
			UI.Alert("This option cannot be used in this game. To be able to use this option, the game creator must have enabled the \"Can attack by percentage\" setting"); 
		end
	end);
	
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

function AddOrdersConfirmes(inputs)	
	if Game.Us.HasCommittedOrders == true then
		UI.Alert("You need to uncommit first");
		return;
	end

	local annotations = {};

	local orders = Game.Orders;
	local territories = Game.LatestStanding.Territories;
	local orderListIndex, endOfList;
	local deployMap = nil;
	local pastOrderListIndex;

	local index = #orders;
	while index > 0 do
        local o = orders[index];
        if o.OccursInPhase and o.OccursInPhase < WL.TurnPhase.ReceiveCards then break; end 
        if o.proxyType == "GameOrderCustom" and o.Payload == payload then
            table.remove(orders, index);
			-- annotations = o.TerritoryAnnotationsOpt;
        end
		index = index - 1;
    end
	
	Timer.Start("Total");
	if inputs.AddDeployments then
		Timer.Start("Init");
		local territoryToBonusMap = Mod.PublicGameData.TerritoryToBonusMap;
		orderListIndex, endOfList = getFirstOrderOfPhase(orders, WL.TurnPhase.Deploys);
		local bonusMap = createBonusMap(Game.LatestStanding);
		local previousBonusMap = createBonusMap(LastStanding);
		deployMap = {};
		Timer.Stop("Init");
		
		-- Update bonusMap with deploy orders already in the order list
		Timer.Start("Current orders");
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
		Timer.Stop("Current orders");
		
		Timer.Start("Past orders");
		pastOrderListIndex = getFirstOrderOfPhase(LastTurn, WL.TurnPhase.Deploys);
		local order = LastTurn[pastOrderListIndex];
		while orderIsBeforePhase(order, WL.TurnPhase.Deploys + 1) do
			if order.proxyType == "GameOrderDeploy" then
				local terrID = order.DeployOn;
				local bonusID = territoryToBonusMap[terrID];
				if deployMap[terrID] == nil and territories[terrID].OwnerPlayerID == Game.Us.ID and previousBonusMap[bonusID] ~= nil and bonusMap[bonusID] ~= nil and bonusMap[bonusID].NumArmies > 0 then
					local num = math.min(bonusMap[bonusID].NumArmies, order.NumArmies);
					table.insert(orders, orderListIndex, WL.GameOrderDeploy.Create(Game.Us.ID, num, terrID, false));
					annotations[terrID] = WL.TerritoryAnnotation.Create("+" .. num, 5);
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
		Timer.Stop("Past orders");
		
		Timer.Start("Deploy last armies")
		if inputs.DeployAllArmies or inputs.AlwaysDeployInSingleTerrBonuses then
			for bonusID, bonus in pairs(bonusMap) do
				if bonus.NumArmies > 0 then
					if bonus.OrderIndex ~= nil and inputs.DeployAllArmies then
						local old = orders[bonus.OrderIndex];
						table.remove(orders, bonus.OrderIndex);
						local num = old.NumArmies + bonus.NumArmies;
						table.insert(orders, bonus.OrderIndex, WL.GameOrderDeploy.Create(Game.Us.ID, num, old.DeployOn, false));
						deployMap[old.DeployOn] = deployMap[old.DeployOn] + bonus.NumArmies;
					elseif inputs.AlwaysDeployInSingleTerrBonuses and isSingleTerrBonus(Game.Map.Bonuses[bonusID]) then
						if bonus.OrderIndex == nil then
							local terrID = getFirstTerritoryOfBonus(Game.Map.Bonuses[bonusID]);
							local num = bonusMap[bonusID].NumArmies;
							table.insert(orders, orderListIndex, WL.GameOrderDeploy.Create(Game.Us.ID, num, terrID, false));
							deployMap[terrID] = bonusMap[bonusID].NumArmies;
							orderListIndex = orderListIndex + 1;
							annotations[terrID] = WL.TerritoryAnnotation.Create("+" .. num, 5);
						else
							local old = orders[bonus.OrderIndex];
							local num = old.NumArmies + bonus.NumArmies;
							table.remove(orders, bonus.OrderIndex);
							table.insert(orders, bonus.OrderIndex, WL.GameOrderDeploy.Create(Game.Us.ID, num, old.DeployOn, false));
							deployMap[old.DeployOn] = deployMap[old.DeployOn] + bonus.NumArmies;
							annotations[old.DeployOn] = WL.TerritoryAnnotation.Create("+" .. num, 5);
						end
					end
				end
			end
		end
		Timer.Stop("Deploy last armies");
	end
	
	
	if inputs.AddTransfers then
		Timer.Start("Init armies map");
		if deployMap == nil then
			deployMap = createDeployMap(orders);
		end
		local armiesMap = createArmiesMap(Game.LatestStanding.Territories, deployMap, inputs.MoveSpecialUnits);
		Timer.Stop("Init armies map");
		local transferMap = {};
		local oneArmyGuard = Game.Settings.OneArmyStandsGuard;
		local noSplit = Game.Settings.NoSplit;
		
		orderListIndex, endOfList = getFirstOrderOfPhase(orders, WL.TurnPhase.Attacks, orderListIndex);
		
		Timer.Start("Current orders");
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
		Timer.Stop("Current orders");
		
		Timer.Start("Past transfer");
		pastOrderListIndex = getFirstOrderOfPhase(LastTurn, WL.TurnPhase.Attacks, pastOrderListIndex or 1);
		print("Start transfers order index: " .. pastOrderListIndex);
		local order = LastTurn[pastOrderListIndex];
		while orderIsBeforePhase(order, WL.TurnPhase.Attacks + 1) do
			if order.proxyType == "GameOrderAttackTransfer" and order.PlayerID == Game.Us.ID then
				local from = order.From;
				local to = order.To;
				if territories[from].OwnerPlayerID == Game.Us.ID and isTeamMate(Game.Game.Players[territories[to].OwnerPlayerID]) and not order.Result.IsAttack and (transferMap[from] == nil or not transferInList(transferMap[from], to)) then
					if not inputs.RemoveZeroTransfers or (not oneArmyGuard and not armiesMap[from].IsEmpty) or (oneArmyGuard and armiesMap[from].NumArmies > 1) then
						local armies;
						if noSplit then
							local n = armiesMap[from].NumArmies;
							if oneArmyGuard then
								n = math.max(n - 1, 0)
							end
							armies = WL.Armies.Create(n);
						else
							if not order.ByPercent and not inputs.SetToPercentage then
								local n = 0;
								if order.NumArmies.NumArmies > armiesMap[from].NumArmies then
									n = order.NumArmies.NumArmies - armiesMap[from].NumArmies;
									if oneArmyGuard then
										n = math.max(n + 1, 0)
									end
								end
								armies = order.NumArmies.Subtract(WL.Armies.Create(n, order.NumArmies.SpecialUnits or {}));
							elseif order.ByPercent then
								armies = order.NumArmies.Subtract(WL.Armies.Create(0, order.NumArmies.SpecialUnits or {}));
							else
								armies = WL.Armies.Create(100);
							end
						end
						local new = WL.GameOrderAttackTransfer.Create(Game.Us.ID, from, to, order.AttackTransfer, inputs.SetToPercentage or order.ByPercent, armies, order.AttackTeammates);
						table.insert(orders, new);
						transferMap[from] = transferMap[from] or {};
						table.insert(transferMap[from], { To = to, OrderIndex = orderListIndex });
						if annotations[from] then
							annotations[from] = WL.TerritoryAnnotation.Create(annotations[from].Message .. ", -" .. armies.NumArmies .. (((inputs.SetToPercentage or order.ByPercent) and "%") or ""), 5);
						else
							annotations[from] = WL.TerritoryAnnotation.Create("-" .. armies.NumArmies .. (((inputs.SetToPercentage or order.ByPercent) and "%") or ""), 5);
						end
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
		print("end transfers order index: " .. pastOrderListIndex);
		Timer.Stop("Past transfer");
		
		
		if inputs.MoveUnmovedArmies or inputs.MoveSpecialUnits then
			Timer.Start("Add forgotten units")
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
					if index ~= nil then
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
							if annotations[terrID] then
								annotations[terrID] = WL.TerritoryAnnotation.Create(string.gsub(annotations[terrID].Message, "-%d+", "-" .. newArmies.NumArmies, 1), 5);
							else
								annotations[terrID] = WL.TerritoryAnnotation.Create("-" .. newArmies.NumArmies, 5);
							end
						end
					end
				end
			end
			Timer.Stop("Add forgotten units")
		end
		
	end
	local customOrderIndex = 0;
    for i = #orders, 1, -1 do
		local order = orders[i];
        if order.OccursInPhase ~= nil and order.OccursInPhase < WL.TurnPhase.ReceiveCards then
            customOrderIndex = i;
            break;
        end
    end
    if customOrderIndex == 0 then customOrderIndex = #orders + 1; end
	local custom = WL.GameOrderCustom.Create(Game.Us.ID, "Additions by the LD Helper mod", payload, {}, WL.TurnPhase.ReceiveCards);
	custom.TerritoryAnnotationsOpt = annotations;
	-- table.insert(orders, customOrderIndex + 1, custom);
	Game.Orders = copyTable(orders);
	Timer.Stop("Total");

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
	if p == nil then return false; end
	return p.ID == Game.Us.ID or (p.Team ~= -1 and p.Team == Game.Us.Team);
end

function AddOrdersHelper(inputs)
	Close();
	standing = Game.LatestStanding;

	if Game.Game.TurnNumber - 2 >= 0 then
		Game.GetTurn(Game.Game.TurnNumber - 2, function(turn) 
			LastTurn = turn.Orders; 
			Game.GetStanding(Game.Game.TurnNumber - 2, 0, function(standing) 
				LastStanding = standing; 
				AddOrdersConfirmes(inputs); 
			end);		
		end);
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
		return {AddDeployments = true, AlwaysDeployInSingleTerrBonuses = not Game.Settings.CommerceGame, DeployAllArmies = not Game.Settings.CommerceGame; AddTransfers = true, SetToPercentage = false, RemoveZeroTransfers = true, MoveUnmovedArmies = true, MoveSpecialUnits = false };
	else
		return Mod.PlayerGameData.SavedInputs;
	end
end