require("UI");
function Client_PresentConfigureUI(rootParent)
	init(rootParent);
	initValues();
	local vert = newVerticalGroup("vert", "root");
	
	newLabel("flagsPerTeam", vert, "Number of flags per team", "Cyan");
	amountOfFlags = newNumberField("nFlags", vert, 1, 5, flagsPerTeam);
	
	newLabel("nFlagsForLose", vert, "The number of flags a team has to lose to be eliminated", "Cyan");
	loseCondition = newNumberField("loseCondition", vert, 1, 5, nFlagsForLose);
	
	newLabel("incomeBoostDesc", vert, "The amount of (permanent) extra income a player gets on capturing a flag", "Cyan");
	incomeIncrement = newNumberField("incomeIncrement", vert, 1, 10, incomeBoost);

	newLabel("movement cooldown", vert, "After moving a Flag, players cannot move that Flag for X more turns");
	moveCooldown = newNumberField("moveCooldown", vert, 0, 5, cooldown);
end

function initValues()
	flagsPerTeam = Mod.Settings.FlagsPerTeam; if flagsPerTeam == nil then flagsPerTeam = 1; end
	nFlagsForLose = Mod.Settings.NFlagsForLose; if nFlagsForLose == nil then nFlagsForLose = 1; end
	incomeBoost = Mod.Settings.IncomeBoost; if incomeBoost == nil then incomeBoost = 3; end
	cooldown = Mod.Settings.Cooldown; if cooldown == nil then cooldown = 1; end
end