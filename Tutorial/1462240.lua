-- Tutorial: Gift Armies

function initTutorial()
	UIfunctions = {tutorialStart, stageTwo, stageThree, stageFour, stageFive, stageSix}
	checkFunctions = {checkTutorialStart, checkStageTwo, checkStageThree, checkStageFour, checkStageFive};
	inputs = {};
	SetWindow("tutorialMain");
	CreateLabel(Vert).SetText("Tutorial: Gift Armies").SetColor(Colors["Royal Blue"]);
	CreateEmpty(Vert).SetPreferredHeight(20);
	local vert = CreateVert(Vert);
	CreateEmpty(Vert).SetPreferredHeight(10);
	checkButton = CreateButton(Vert).SetText("Check tasks").SetOnClick(checkFunctions[Mod.PlayerGameData.Progress]).SetColor(Colors["Green"]).SetInteractable(Mod.PlayerGameData.FurtestStage == nil or Mod.PlayerGameData.FurtestStage <= Mod.PlayerGameData.Progress);
	CreateEmpty(Vert).SetPreferredHeight(20);
	local line = CreateHorz(Vert);
	print(Mod.PlayerGameData.Progress)
	previousButton = CreateButton(line).SetText("Previous").SetOnClick(function() Close(); Game.SendGameCustomMessage("Updating progress...", {Type="WentBack"}, function() end) end).SetColor(Colors["Lime"]).SetPreferredWidth(100).SetInteractable(Mod.PlayerGameData.Progress > 1);
	nextButton = CreateButton(line).SetText("Next").SetOnClick(function() Close(); Game.SendGameCustomMessage("Updating progress...", {Type="CompletedStage"}, function() end); end).SetColor(Colors["Lime"]).SetPreferredWidth(100).SetInteractable(Mod.PlayerGameData.FurtestStage ~= nil and Mod.PlayerGameData.FurtestStage > Mod.PlayerGameData.Progress);
	UIfunctions[Mod.PlayerGameData.Progress](vert);
end

function tutorialStart(vert)
	SetWindow("tutorial");
	nextButton.SetInteractable(true);
	UI.Destroy(checkButton);
	CreateLabel(vert).SetText("Welcome to the Gift Armies tutorial! This mod is mostly used in team and diplomatic games. It allows players to give armies to another player without being on the same team as them. The armies are randomly distributed over all the territory the player has\n\nImagine you're a big party in the game. You've got income and / or armies enough and you have allies across the ocean. Your ally has been pushed back to France, and will likely be eliminated from the game if you do nothing. ");
end

function checkTutorialStart()
	return true; 	-- No tasks
end

function stageTwo(vert)
	SetWindow("tutorial");
	CreateLabel(vert).SetText("Luckily we can help them out! In the green [Game ^] button in the bottom left corner you will find a light grey button [Mod: Gift Armies]. If you press this button an menu just like this one pops up. In here you will be able to gift armies to your teammate.\n\nOnce you've opened the menu, you'll see 2 lines of texts with a button besides it. The first button allows you to pick the player you want to give the armies to. Pick the player you're on the same team with, otherwise you'll give an opponent the armies. When you've picked the player you want to give the armies to, the text on the button will change to the name of the player picked by you.\n\nThe next button allows you to pick a territory that you own as a source. Since we have 250 armies on 'New England' we want to select it as our source territory.\n\nNow another bit of text pops up with something what we call an number input. Here you can configure how many armies you want to give. Set this to at least 200 or more\n\nNow we can push the last button that says [Gift]. In your orderlist should now be an order with the following text: 'Gifting 2## armies from New England to *player name*'");
	CreateEmpty(vert).SetPreferredHeight(5);
	table.insert(inputs, CreateLabel(vert).SetText("Create a order following the steps above").SetColor(getStringColor()));
end

function checkStageTwo()
	local hasOrder = false;
	for _, order in pairs(Game.Orders) do
		if order.proxyType == "GameOrderCustom" then		-- GiftArmies_250,46,1
			local firstSplit = split(order.Payload, "_");
			if firstSplit[1] == "GiftArmies" then
				local data = split(firstSplit[2], ",");
				if tonumber(data[1]) >= 200 and tonumber(data[2]) == 46 and tonumber(data[3]) == 1 then
					hasOrder = true;
					break;
				end
			end
		end
	end
	if hasOrder then
		inputs[1].SetColor(Colors["Green"]);
		finishedAllTasks();
	else
		inputs[1].SetColor(Colors["Orange Red"]);
	end
end

function stageThree(vert)
	SetWindow("tutorial");
	CreateLabel(vert).SetText("Now deploy your armies somewhere. It doesn't matter where you deploy them, but do deploy all of them.");
	table.insert(inputs, CreateLabel(vert).SetText("Deploy all your armies (0 / " .. Game.Us.Income(0, Game.LatestStanding, false, false).Total .. ")").SetColor(getStringColor()));
end

function checkStageThree()
	local totalDeployed = 0;
	for _, order in pairs(Game.Orders) do
		if order.proxyType == "GameOrderDeploy" then
			totalDeployed = totalDeployed + order.NumArmies;
		end
	end
	if totalDeployed == Game.Us.Income(0, Game.LatestStanding, false, false).Total then
		inputs[1].SetText("Deploy all your armies (" .. Game.Us.Income(0, Game.LatestStanding, false, false).Total .. " / " .. Game.Us.Income(0, Game.LatestStanding, false, false).Total .. ")").SetColor(Colors["Green"]);
		finishedAllTasks();
	else
		inputs[1].SetText("Deploy all your armies (" .. totalDeployed .. " / " .. Game.Us.Income(0, Game.LatestStanding, false, false).Total .. ")").SetColor(Colors["Red"]);
	end
end

function stageFour(vert)
	SetWindow("tutorial");
	CreateLabel(vert).SetText("Now notice how your deployment order(s) were put before the armies gift order. Warzone wants each order to be in the right phase, deployments are in the deployment phase and attack / transfers are in the attack / transfer phase.\n\nIt is therefore VERY good to know that the Gift Armies order is a special kind of order. It does not has a phase it needs to be in. Sometimes mods force these orders to be played at a specific moment, but not the Gift Armies mod. \n\nYou can move the Gift Armies order all the way to the top of your order list. If the order is processed as first of all your orders, you'll be guaranteed that the actions the order will start happen all the way at the very start of the turn. Here in this example we want to gift the armies as soon as possible.");
	CreateEmpty(vert).SetPreferredHeight(5);
	table.insert(inputs, CreateLabel(vert).SetText("Move the Gift armies order before any deployment order").SetColor(getStringColor()));
end

function checkStageFour()
	if Game.Orders[1].proxyType == "GameOrderCustom" then
		local firstSplit = split(Game.Orders[1].Payload, "_");
		if firstSplit[1] == "GiftArmies" then
			local data = split(firstSplit[2], ",");
			if tonumber(data[1]) >= 200 and tonumber(data[2]) == 46 and tonumber(data[3]) == 1 then
				inputs[1].SetColor(Colors["Green"]);
				finishedAllTasks();
				return;
			end
		end
	end
	inputs[1].SetColor(Colors["Orange Red"]);
end

function stageFive(vert)
	SetWindow("tutorial");
	CreateLabel(vert).SetText("You also have around 250 armies doing nothing around 'Great Plains' (middle of the USA). We're going to send all these armies to your ally too, but in one order.\n\nFirst we need to gather all the armies in one place. 'Great Plains' is exactly in the middle of all the armies, so we're going to send all the armies to there.\n\nNow, open the Gift Armies mod menu to create a Gift Armies order, give the armies to AI 1 and set the source territory to 'Great Plains'. Now we see that the mod tells us we have 0 armies on that specific territory. That is not a problem, press the box with the 0 in it to input another number that is at least 300 or more.\n\nThis works because the mod will only check how many armies there are on the source territory when processing the order. So when it detects it has 300 armies, it will give these 300 armies to the player. When there are less armies on the territory than the Gift Armies order is looking for, it will take all the armies");
	CreateEmpty(vert).SetPreferredHeight(5);
	table.insert(inputs, CreateLabel(vert).SetText("Move at least 250 armies to 'Great Plains' (0 / 250)").SetColor(getStringColor()));
	table.insert(inputs, CreateLabel(vert).SetText("Create a second Gift Armies order with the specifications above").SetColor(getStringColor()));
end

function checkStageFive()
	local hasOrder = false;
	local finished = true;
	local totalMovedArmies = 0;
	for _, order in pairs(Game.Orders) do
		if order.proxyType == "GameOrderAttackTransfer" then
			if order.To == 41 then
				totalMovedArmies = totalMovedArmies + order.NumArmies.NumArmies;
			end
		elseif order.proxyType == "GameOrderCustom" then
			local firstSplit = split(order.Payload, "_");
			if firstSplit[1] == "GiftArmies" then
				local data = split(firstSplit[2], ",");
				if tonumber(data[1]) >= 300 and tonumber(data[2]) == 41 and tonumber(data[3]) == 1 then
					hasOrder = true;
				end
			end
		end
	end
	if totalMovedArmies >= 250 then
		inputs[1].SetColor(Colors["Green"]);
	else
		inputs[1].SetColor(Colors["Orange Red"]);
		finished = false;
	end
	inputs[1].SetText("Move at least 250 armies to 'Great Plains' (" .. totalMovedArmies .. " / 250)");
	if hasOrder then
		inputs[2].SetColor(Colors["Green"]);
	else
		inputs[2].SetColor(Colors["Orange Red"]);
		finished = false;
	end
	if finished then
		finishedAllTasks();
	end
end

function stageSix(vert)
	SetWindow("tutorial");
	CreateLabel(vert).SetText("Now you can commit your turn and watch the turn back.\n\nIf all went right this is what happened:\nFirst, your Gift Armies order gave 250 armies to AI 1 which got randomly distributed over his 2 territories. The deployments happened and AI 2 attacked France, while you transferred your armies towards 'Great Plains'. All the way at the end of the turn, your second Gift Armies order gifts AI 1 another 250+ armies.\n\nThis was the tutorial for Gift Armies! You can press the [Next] button whenever you're done reading this. I hope you learned something from my efforts ;)");
	UI.Destroy(checkButton);
	nextButton.SetInteractable(true).SetOnClick(function() Close(); Game.SendGameCustomMessage("Updating progress...", {Type="ResetProgress"}, function() end); end);
end
