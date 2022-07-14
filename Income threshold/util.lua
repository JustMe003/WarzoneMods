function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end


function getIncomeThreshold(n)
	if Mod.Settings.Formula == "ax + c" then
		return Mod.Settings.A * n + Mod.Settings.C;
	else
		return Mod.Settings.A * n * n + Mod.Settings.B * n + Mod.Settings.C;
	end
end