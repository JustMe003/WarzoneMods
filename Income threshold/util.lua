function round(n)
	if n % 1 > 0.5 then
		return math.ceil(n);
	else
		return math.floor(n);
	end
end

function getIncomeThreshold(n)
	if Mod.Settings.Formula == "ax + c" then
		return Mod.Settings.A * n + Mod.Settings.C;
	else
		return Mod.Settings.A * n * n + Mod.Settings.B * n + Mod.Settings.C;
	end
end