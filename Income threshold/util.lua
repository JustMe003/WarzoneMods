function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function getIncomeThreshold(n)
	local choice_table =
	{
		["a.x + c"] = Mod.Settings.A * n + Mod.Settings.C,
		["a.x² + b.x + c"] = Mod.Settings.A * n^2 + Mod.Settings.B * n + Mod.Settings.C,
		["a.x² + d.x.√x + b.x + e.√x + c"] = Mod.Settings.A * n^2 + Mod.Settings.D * n^1.5 + Mod.Settings.B * n + Mod.Settings.E * n^0.5 + Mod.Settings.C,
		["a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c"] = Mod.Settings.A * n^2 + Mod.Settings.D * n^1.5 + Mod.Settings.B * n + Mod.Settings.E * n^0.5 + Mod.Settings.F * math.log(n) + Mod.Settings.C,
	}
	return choice_table[Mod.Settings.Formula]
end

function getPower(b, p)
	if p == 0 then return 1; end
	return b * getPower(b, p - 1);
end

function isIn(value, list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set[value] or false
end