function Client_SaveConfigureUI(alert)
	Mod.Settings.Data = getText(data);
	Mod.Settings.Testing = getIsChecked(testingScenario);
	
	if #Mod.Settings.Data == 0 then return; end
	local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ:;'\"/?>,<-_=+!@#&*.^%()";
	for i = 1, #chars do
		if string.find(Mod.Settings.Data, string.sub(chars, i, i), 1, true) ~= nil then print(string.sub(chars, i, i)); alert("The data string contains wrong characters! Please do not make any manual modifications"); end
	end
	
	local openCount = 0;
	local closeCount = 0;
	for i = 1, #Mod.Settings.Data do
		local c = string.sub(Mod.Settings.Data, i, i);
		if c == "{" then openCount = openCount + 1; end
		if c == "}" then closeCount = closeCount + 1; end
	end
	
	if openCount ~= closeCount then alert("The data string does not have the right format! Please do not make any manual modifications"); end
	
	local startID = string.find(Mod.Settings.Data, "%[");
	if startID ~= nil then
		startID = startID + 1;
	else
		alert("The data string does not have the right format! Please do not make any manual modifications")
	end
	local endID = string.find(Mod.Settings.Data, "%]");
	if endID ~= nil then
		endID = endID - 1;
	else
		alert("The data string does not have the right format! Please do not make any manual modifications");
	end
	local mapID = tonumber(string.sub(Mod.Settings.Data, startID, endID));
	if mapID == nil then
		alert("The data string does not have the right format! Please do not make any manual modifications");
	end
end