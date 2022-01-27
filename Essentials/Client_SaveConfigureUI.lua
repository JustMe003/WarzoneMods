require("UI");
require("utilities");

function Client_SaveConfigureUI(alert)
	local t = {};
	for _, mod in pairs(mods) do
		if allObjects[mod] ~= nil then
			if allObjects[mod].Object.GetIsChecked() then
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