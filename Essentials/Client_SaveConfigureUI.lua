function Client_SaveConfigureUI(alert)
	local t = {};
	for _, mod in pairs(modList) do
		print(mod);
		if objectExists(mod) then
			if getIsChecked(mod) then
				t[mod] = true;
			else
				t[mod] = false;
			end
		else
			t[mod] = false;
		end
	end
	Mod.Settings.Mods = t;
end