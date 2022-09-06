function Server_GameCustomMessage(game, playerID, payload, setReturn)
	local functions = {StartedTutorial=StartedTutorial, CompletedStage=CompletedStage, WentBack=WentBack, ResetProgress=ResetProgress};
	functions[payload.Type](game, playerID, payload, setReturn);
end

function StartedTutorial(game, playerID, payload, setReturn)
	local pd = Mod.PlayerGameData;
	if pd == nil then pd = {}; end
	if pd[playerID] == nil then pd[playerID] = {}; end
	pd[playerID].StartedTutorial = true;
	pd[playerID].Tutorial = payload.Tutorial;
	pd[playerID].Progress = 1;
	Mod.PlayerGameData = pd;
	require(tostring(payload.Tutorial));
end

function CompletedStage(game, playerID, payload, setReturn)
	local pd = Mod.PlayerGameData;
	pd[playerID].Progress = pd[playerID].Progress + 1;
	Mod.PlayerGameData = pd;
end

function WentBack(game, playerID, payload, setReturn)
	local pd = Mod.PlayerGameData;
	if pd[playerID].FurtestStage == nil or pd[playerID].FurtestStage < pd[playerID].Progress then
		pd[playerID].FurtestStage = pd[playerID].Progress;
	end
	pd[playerID].Progress = pd[playerID].Progress - 1;
	Mod.PlayerGameData = pd;
end

function ResetProgress(game, playerID, payload, setReturn)
	local pd = Mod.PlayerGameData;
	pd[playerID] = {};
	Mod.PlayerGameData = pd;
end

