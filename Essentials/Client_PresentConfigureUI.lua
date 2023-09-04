require("UI");
require("utilities");

function Client_PresentConfigureUI(rootParent)
	Init(rootParent);
	root = GetRoot();
	colors = GetColors();

	-- permanent labels
	local line = CreateHorz(root);
	CreateLabel(line).SetText("Mod Author: ").SetColor(colors.TextColor);
	CreateLabel(line).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
	line = CreateHorz(root);
	CreateLabel(line).SetText("Version: ").SetColor(colors.TextColor);
	CreateLabel(line).SetText("2.0").SetColor(colors["Royal Blue"]);
	CreateEmpty(line).SetPreferredHeight(10);

	-- makes sure the lines above stay
	SetWindow("DummyWindow");

	showMain();
end

function showMain()
	DestroyWindow();
	SetWindow("ShowMain");

	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateLabel(line).SetText("Welcome to ").SetColor(colors.TextColor).SetFlexibleWidth(0);
	CreateLabel(line).SetText(" Essentials").SetColor(colors["Royal Blue"]).SetFlexibleWidth(0);
	CreateEmpty(line).SetFlexibleWidth(0.5);

	CreateEmpty(root).SetPreferredHeight(5);
	
	CreateLabel(root).SetText("This mod adds all kinds of essential stuff to your modded AND normal game, such as mod manuals, a order finder, and much more!").SetColor(colors.TextColor);
	CreateLabel(root).SetText("Pick a feature here below to learn more about them").SetColor(colors.TextColor);
	CreateButton(root).SetText("Mod Manuals").SetColor(colors.Lime).SetOnClick(showModManuals);
	CreateButton(root).SetText("Unit Inspector").SetColor(colors.Blue).SetOnClick(showUnitInspector);
	CreateButton(root).SetText("Document links").SetColor(colors.Yellow).SetOnClick(showDocumentLinks);
	CreateButton(root).SetText("Order Finder").SetColor(colors.Orange).SetOnClick(showOrderFinder);
	
	CreateEmpty(root).SetPreferredHeight(5);

	CreateButton(root).SetText("Contact Me").SetColor(colors.Green).SetOnClick(showContactMe);
end

function showModManuals()
	DestroyWindow();
	SetWindow("showModManuals");
	CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
	CreateEmpty(root).SetPreferredHeight(5);
	CreateLabel(root).SetText("This is where this massive project all started...\nI'll won't go into why and how I started it all, you can send me a message if you want to know more about this xD\n\nThese manuals are made for various mods to help players to understand how they work and how they should use them in their advantage. Even more experienced players can use these manuals to improve their playstyle / strategies.\nNow note that these manuals are all made by me, but it takes a lot of time to create one. Therefore there are lot of missing manuals, simply becuase I haven't made them yet. If you want a manual for a specific mod, feel free to contact me about it!").SetColor(colors.TextColor);
end

function showUnitInspector()
	DestroyWindow();
	SetWindow("showUnitInspector");
	CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
	CreateEmpty(root).SetPreferredHeight(5);
	CreateLabel(root).SetText("Now that mods are able to create their own custom units, it is sometimes hard to differentiate which unit is which, how much damage they do, if they can be damaged, etc. This tool allows you to select a unit and it will display all the information it knows, from attack damage to it's description").SetColor(colors.TextColor);
end

function showDocumentLinks()
	DestroyWindow();
	SetWindow("showDocumentLinks");

	local links = links or Mod.Settings.Documents;
	if links == nil then
		links = {};
	end

	CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
	CreateEmpty(root).SetPreferredHeight(5);
	CreateLabel(root).SetText("Sharing (document) links has always been hard in some way. Putting them in the game description makes it impossible for mobile users to copy them, and putting them in the game chat will bury them under tens, maybe hundreds or even more messages. With the help of this mod, Essentials, you can allow all players to copy those documents you want to be available to all!").SetColor(colors.TextColor);

	CreateEmpty(root).SetPreferredHeight(10);
	CreateButton(root).SetText("Add link").SetColor(colors.Blue).SetOnClick(function() links[#links] = modifyLink({Name = "", Link = ""}); showDocumentLinks(); end);
	
	CreateEmpty(root).SetPreferredHeight(5);
	for i, link in pairs(links) do
		CreateButton(root).SetText(link.Name).SetColor(colors.Green).SetOnClick(function() links[i] = modifyLink(link); showDocumentLinks(); end)
	end
end

function modifyLink(link)
	DestroyWindow();
	SetWindow("modifyLink");

	local nameInput = CreateTextInputField(root).SetText(link.Name or "").SetPlaceholderText("Name of the link").SetFlexibleWidth(1);
	local linkInput = CreateTextInputField(root).SetText(link.Link or "").SetPlaceholderText("Browser link").SetFlexibleWidth(1);
	
	CreateEmpty(root).SetPreferredHeight(5);
	local line = CreateHorz(root).SetFlexibleWidth(1);
	CreateEmpty(line).SetFlexibleWidth(0.5);
	CreateButton(line).SetText("Save").SetColor(colors.Green).SetOnClick(function() return {Name = nameInput.GetText(), Link = linkInput.GetText()}; end);
	CreateButton(line).SetText("Cancel").SetColor(colors.Red).SetOnClick(showDocumentLinks);
	CreateEmpty(line).SetFlexibleWidth(0.5);
end

function showOrderFinder()
	DestroyWindow();
	SetWindow("showOrderFinder");
	CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
	CreateEmpty(root).SetPreferredHeight(5);
	CreateLabel(root).SetText("[!] UNDER MAINTENANCE [!]").SetColor(colors.TextColor);
end

function showContactMe()
	DestroyWindow();
	SetWindow("showContactMe");
	CreateButton(root).SetText("Return").SetColor(colors.Orange).SetOnClick(showMain);
	CreateEmpty(root).SetPreferredHeight(5);
	CreateLabel(root).SetText("Any questions or remarks about this or another mod? Please contact me about it! I can do a lot of things on my own, but together we can make Warzone even better!").SetColor(colors.TextColor);
	CreateTextInputField(root).SetText("https://www.warzone.com/Discussion/SendMail?PlayerID=1311724").SetPreferredWidth(300);
	CreateLabel(root).SetText("Copy-paste this URL into a browser to send me a mail.\n\nRather use Discord than Warzone Mail? Contact me using my Discord username here below").SetColor(colors.TextColor);
	CreateTextInputField(root).SetText("Just_A_Dutchman#2582").SetPreferredWidth(300);
end


-- testing only
