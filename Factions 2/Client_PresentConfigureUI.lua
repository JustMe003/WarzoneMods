function Client_PresentConfigureUI(rootParent)
	if Mod.Settings.VersionNumber ~= nil then
		if Mod.Settings.VersionNumber == 1 then
			require("Client_PresentConfigureUI1");
		else
			require("Client_PresentConfigureUI2");
		end
		Client_PresentConfigureUIMain(rootParent);
	else
		local t = {};
		local vert = UI.CreateVerticalLayoutGroup(rootParent);
		table.insert(t, UI.CreateLabel(vert).SetText("Pick which mod version you want to use"));
		table.insert(t, UI.CreateButton(vert).SetText("Version: 1.5").SetColor("#0000FF").SetOnClick(function() cleanUpWindow(t); require("Client_PresentConfigureUI1"); Version = 1; Client_PresentConfigureUIMain(vert); end));
		table.insert(t, UI.CreateButton(vert).SetText("Version: 2.3").SetColor("#0000FF").SetOnClick(function() cleanUpWindow(t); require("Client_PresentConfigureUI2"); Version = 2; Client_PresentConfigureUIMain(vert); end));
	end
end

function cleanUpWindow(t)
	for _, o in pairs(t) do
		UI.Destroy(o);
	end
end