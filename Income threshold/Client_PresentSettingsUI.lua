require("UI");
require("util");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	local vert = newVerticalGroup("vert", "root");

	local choice_table =
	{
		["a.x + c"] = "x + ",
		["a.x² + b.x + c"] = "x² + " .. round(Mod.Settings.B, 2) .. "x + ",
		["a.x² + d.x.√x + b.x + e.√x + c"] = "x² + " .. round(Mod.Settings.D, 2) .. "x.√x + " .. round(Mod.Settings.B, 2) .. "x + " .. round(Mod.Settings.E, 2) .. "√x + ",
		["a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c"] = "x² + " .. round(Mod.Settings.D, 2) .. "x.√x + " .. round(Mod.Settings.B, 2) .. "x + " .. round(Mod.Settings.E, 2) .. "√x + ".. round(Mod.Settings.F, 2) .. "lnx + ",
	}
	newLabel("formula", vert, "Formula: " .. round(Mod.Settings.A, 2) .. choice_table[Mod.Settings.Formula] .. Mod.Settings.C, "Royal Blue");

	newLabel("empty", vert, "\n");
	for k = 0, 8 do
		local i = getPower(2, k);
		local choice_table =
		{
			["a.x + c"] = Mod.Settings.A * i,
			["a.x² + b.x + c"] = Mod.Settings.A * i^2 + Mod.Settings.B * i,
			["a.x² + d.x.√x + b.x + e.√x + c"] = Mod.Settings.A * i^2 + Mod.Settings.D * i^1.5 + Mod.Settings.B * i + Mod.Settings.E * i^0.5,
			["a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c"] = Mod.Settings.A * i^2 + Mod.Settings.D * i^1.5 + Mod.Settings.B * i + Mod.Settings.E * i^0.5 + Mod.Settings.F * math.log(i),
		}
		newLabel(i, vert, "after " .. i .. " turns:   " .. math.ceil(choice_table[Mod.Settings.Formula] + Mod.Settings.C))
	end
end