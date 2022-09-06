function templateIsTutorial(id);
	return valueInTable({1462240}, id);
end

function readableString(s)
	local ret = string.upper(string.sub(s, 1, 1));
	for i = 2, #s do
		if string.sub(s, i, i) == string.lower(string.sub(s, i, i)) then
			ret = ret .. string.sub(s, i, i);
		else
			ret = ret .. " " .. string.lower(string.sub(s, i, i));
		end
	end
	return ret;
end

function getStringColor()
	if Mod.PlayerGameData.FurtestStage ~= nil and Mod.PlayerGameData.FurtestStage > Mod.PlayerGameData.Progress then
		return Colors["Green"];
	else
		return Colors["Orange"];
	end
end

function getShouldBeInteractable()
	return Mod.PlayerGameData.FurtestStage == nil or Mod.PlayerGameData.FurtestStage <= Mod.PlayerGameData.Progress;
end

function valueInTable(t, v)
	for _, v2 in pairs(t) do
		if v2 == v then return true; end
	end
	return false;
end

function finishedAllTasks()
	nextButton.SetInteractable(true);
	checkButton.SetInteractable(false);
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end
