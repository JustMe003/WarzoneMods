require("UI");
require("util");
function Client_PresentSettingsUI(rootParent)
	init(rootParent);
	local vert = newVerticalGroup("vert", "root");
	if Mod.Settings.Formula == "ax + c" then
		newLabel("formula", vert, "Formula: " .. round(Mod.Settings.A, 2) .. "x + " .. Mod.Settings.C, "Royal Blue");
	else
		newLabel("formula", vert, "Formula: " .. round(Mod.Settings.A, 2) .. "x² + " .. round(Mod.Settings.B, 2) .. "x + " .. Mod.Settings.C, "Royal Blue");
	end
	newLabel("empty", vert, "\n");
	for k = 0, 7 do
		local i = getPower(2, k);
		if Mod.Settings.Formula == "ax + c" then		
			newLabel(i, vert, "after " .. i .. " turns:   " .. math.ceil(Mod.Settings.A * i + Mod.Settings.C));
		else
			newLabel(i, vert, "after " .. i .. " turns:   " .. math.ceil(i * i * Mod.Settings.A + Mod.Settings.C + Mod.Settings.B * i));
		end
	end
end


function getPower(b, p)
	if p == 0 then return 1; end
	return b * getPower(b, p - 1);
end
