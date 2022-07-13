function Client_SaveConfigureUI(alert)
	Mod.Settings.Formula = getText(win .. "Formula")
	Mod.Settings.A = getValue(win .. "InputA");
	Mod.Settings.C = getValue(win .. "InputC");
	if Mod.Settings.Formula ~= "ax + c" then
		Mod.Settings.B = getValue(win .. "InputB");	
	end
end