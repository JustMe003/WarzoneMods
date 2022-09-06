-- Tutorial: Tutorial

function initTutorial()
	UIfunctions = {tutorialStart, stageTwo, stageThree, finalStage}
	checkFunctions = {checkTutorialStart, checkStageTwo, checkStageThree, checkFinalStage};
	inputs = {};
	SetWindow("tutorialMain");
	CreateLabel(Vert).SetText("Tutorial: Tutorial mod").SetColor(Colors["Royal Blue"]);
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
	CreateLabel(vert).SetText("This mod is not your normal, reqular mod which alters / adds a game mechanic or a useful tool to use for creating a game or to ease something during the game. \n\nThis mod will only work if you use one of the right templates, made for this mod. These templates are specifically build to act as a tutorial, manipulating and modifiying everything if needed to let you understand a mod better. \n\nHow will this work?\nThis mod will explain something and might give you a task. These tasks are meant to let you use the mod and to learn how you can use the mod the most efficiently. \n\nFor now, press the [Next] button to proceed.");
end

function checkTutorialStart()
	return true;		-- no tasks or questions
end

function stageTwo(vert)
	SetWindow("tutorial");
	CreateLabel(vert).SetText("As you've might have noticed, the window briefly closed and then re-opened itself. This process must be used to keep track of where you are in a tutorial, otherwise you'll lose your progress and have to always start all over again if you close this window. You can always close this window if you want to, your progress will not be lost.\n\nThe mod unfortunately cannot keep track of everything. You can alter the slider below and close the menu, but the value will always reset itself to 5. You can test it out below");
	table.insert(inputs, CreateNumberInputField(vert).SetSliderMinValue(1).SetSliderMaxValue(10).SetValue(5).SetInteractable(getShouldBeInteractable()));
	CreateLabel(vert).SetText("Now, time for your first task. Set the slider above to 7 and press the [Check tasks] button. It you have inputted the right value, it will allow you to press the [Next] button and lock the slider");
end

function checkStageTwo()
	if inputs[1].GetValue() == 7 then
		inputs[1].SetInteractable(false);
		finishedAllTasks();
	end
end

function stageThree(vert)
	SetWindow("tutorial");
	CreateLabel(vert).SetText("Let's quickly go over a few tasks you might have to perform. You've already met the number input, which only allows you to input a number. Apart from inputs in this menu, this mod will mostly ask to perform certain tasks in Warzone itself. This can be anything ranging from deploying armies to ordering some attacks.\n\nYour next task is the following, create");
	table.insert(inputs, CreateLabel(vert).SetText("1 attack / transfer order").SetColor(getStringColor()));
end

function checkStageThree()
	local attackTransferCount = 0;
	for _, order in pairs(Game.Orders) do
		if order.proxyType == "GameOrderAttackTransfer" then
			attackTransferCount = attackTransferCount + 1;
		end
	end
	if attackTransferCount > 0 then
		inputs[1].SetColor(Colors["Green"]);
		finishedAllTasks();
	else
		inputs[1].SetColor(Colors["Orange Red"]);
	end
end

function finalStage(vert)
	SetWindow("tutorial");
	CreateLabel(vert).SetText("Unfortunately, the mod cannot check every action you make. Sometimes a tutorial wants you to perform a certain task it cannot check. This does not mean you shouldn't perform the task though, not performing the task will result in non-understandable explanations since the tutorial assumes you performed the task. \n\nWhen the mod ask you to perform this kind of a task it will most likely have a check box that you can tick when you're done. \n\nNow, if you have finished reading this and understand everything what has been explained so far, you may tick the checkbox and press the [Check tasks] button. It will bring you back to the main page where you can do this tutorial again or start the other tutorial.");
	local line = CreateHorz(vert);
	table.insert(inputs, CreateCheckBox(line).SetText(" ").SetIsChecked(false).SetInteractable(getShouldBeInteractable()));
	table.insert(inputs, CreateLabel(line).SetText("I have read this.").SetColor(getStringColor()));
end

function checkFinalStage()
	if inputs[1].GetIsChecked then
		inputs[1].SetInteractable(false);
		inputs[2].SetColor(Colors["Green"]);
		finishedAllTasks();
		nextButton.SetOnClick(function() Close(); Game.SendGameCustomMessage("Updating progress...", {Type="ResetProgress"}, function() end); end);
	else
		inputs[2].SetColor(Colors["Orange Red"]);
	end
end