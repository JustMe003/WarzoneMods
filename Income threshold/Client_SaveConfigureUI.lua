function Client_SaveConfigureUI(alert)
	Mod.Settings.Formula = getText(win .. "Formula")
	Mod.Settings.A = getValue(win .. "InputA");
	Mod.Settings.C = getValue(win .. "InputC");
	if Mod.Settings.Formula ~= "a.x + c" then
		Mod.Settings.B = getValue(win .. "InputB");
	else
		Mod.Settings.B = 0;
	end
	if Mod.Settings.Formula == "a.x² + d.x.√x + b.x + e.√x + c" then
		Mod.Settings.D = getValue(win .. "InputD");
		Mod.Settings.E = getValue(win .. "InputE");
	else
		Mod.Settings.D = 0;
		Mod.Settings.E = 0;
	end
	if Mod.Settings.Formula == "a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c" then
		Mod.Settings.D = getValue(win .. "InputD");
		Mod.Settings.E = getValue(win .. "InputE");
		Mod.Settings.F = getValue(win .. "InputF");
	else
		Mod.Settings.F = 0;
	end
end