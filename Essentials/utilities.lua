function getMods()
	return {"Buy Neutral", "Diplomacy", "Gift Armies", "Gift Gold", "Picks Swap", "Randomized Bonuses", "Randomized Wastelands", "Advanced Diplo Mod V4", "AIs don't deploy", "Buy Cards", "Commerce Plus", "Custom Card Package", "Diplomacy 2", "Late Airlifts", "Limited Attacks", "Limited Multiattacks", "Neutral Moves", "Safe Start", "Swap Territories", "Take Turns", "AI's don't play cards", "Better don't fail an attack", "Bonus Airlift", "BonusValue QuickOverrider", "Connected Commander", "Deployment Limit", "Don't lose a territory", "Extended Randomized Bonuses", "Extended Winning Conditions", "Forts", "Gift Armies 2", "Hybrid Distribution", "Hybrid Distribution 2", "Infromations for spectaters", "King of the Hills", "Lotto Mod -> Instant Random Winner", "More_Distributions", "One Way Connections", "Random Starting Cities", "Runtime Wastelands", "Spawnbarriers", "Special units are medics", "Stack Limit", "Transport Only Airlift"}
end

function getStatus(mod)
	local index;
	for i, v in pairs(getMods()) do if mod == v then index = i; end end
	if index <= 7 then 
		return "trusted"; 
	elseif index <= 20 then 
		return "standard"; 
	else 
		return "experimental"; 
	end
end

function getContents(path)
	local indexes = split(path, "/")
	local ret = mods;
	for _, i in pairs(indexes) do
		ret = ret[i];
	end
	return ret;
end


function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end


function initManuals()
	local bugFreeMessage = "This mod is bug free as far as I know. If you do find a bug please send the mod creator or me a message with the following:\n -  A description of the bug\n -  The link to the game\n\nJust_A_Dutchman_: (https://www.warzone.com/Discussion/SendMail?PlayerID=1311724)";
	local compatibilityAllMessage = "This mod can be used with every other mod / setting in Warzone. If you do find something please send me a message with the following:\n -  A description of what happened or should have happened\n -  The link to the game\n - The turn number where it happened\n\nJust_A_Dutchman_: (https://www.warzone.com/Discussion/SendMail?PlayerID=1311724)";
	mods = {};
	-- Buy Neutral
	-- Diplomacy
	-- Gift Armies
	mods["Gift Gold"] = {};
	mods["Gift Gold"]["Mod description"] = "Allows players to gift gold to another player in commerce games, friend or foe. This mod should only be used in commerce games, as it has no effect otherwise. \n\nTo use it, select Gift Gold from the game's menu, how much gold to give, and which player you wish to give it to. The gold will be given immediately, and can be spent by the receiving player right away. \n\nOne use of this mod is for team games where you wish to share gold amongst your teammates.";
	mods["Gift Gold"]["How to use"] = "This mod is menu-based, meaning that players must use the mod via the menu provided by the mod author. When you open the menu you’ll see a window pop up. This window has 3 different inputs you’ll have to use / specify before the mod can give gold to someone. The first one being the [Select player…] button. When you tap / click this button another window will pop up and the mod prompts you to choose a player out of a list of all players excluding yourself. Choose the player you want to give the gold to and the window will close, returning to the first window that was kept open. Instead of “select player…” it will now say the player you’ve chosen. \n\nThe next input we have to specify is the amount of gold we would like to give away to the player. You can alter the amount of gold by using the slider or number input field. Once you have specified the amount of gold there is only 1 input left for us to use.At last, we tap / click on the [Gift] button. We get a pop up that the gold has been sent, and it tells us how much gold we have left. The receiver receives his gold immediately and your gold gets modified too.";
	mods["Gift Gold"]["how to set up"] = "This mod requires the game to be a commerce game. Armies are a different thing than gold and the mod only is able to give gold away to players. As host, you must therefore set the game to commerce manually since the mod doesn’t overwrite this setting. ";
	mods["Gift Gold"]["Bugs"] = "When gifting gold at T0 the value in the top left doesn’t get updated. When you did give gold away and did your turn normally (spending too much gold) the game will not accept your turn until you’ve adjusted your gold spend.";
	mods["Gift Gold"]["Compatibility"] = compatibilityAllMessage;
	-- Picks Swap
	-- Randomized Bonuses
	-- Randomized Wastelands
	mods["Advanced Diplo Mod V4"] = {};
	mods["Advanced Diplo Mod V4"]["Mod description"] = "Don't use this mod with any other mod with a notifications system, else it may happen that the notifications don't show up. \n\nThis Mod adds: War/Peace System: \n - Attacks DON'T count as declaration \n - After you declared War on someone, you have to wait one turn before you can attack him \n - Sanction, Bomb, Gift, Spy Card can be configurated, that they are just playable if you are in war/peace/ally with the persons you play them on\n - you start at peace with everyone \n\nAlliance System: can be disabled over settings\n - You will be able to see the territories your ally owners (requires spycards to be in the game)(depends on settings)\n - Alliances can be either public or private(depends on the settings)\n - After you cancel an alliance you gotta wait till the next turn to declare war\n\nAIs for Diplos:\n - AIs won't declare war on players(depends on settings)\n - AIs won't declare war on AIs(depends on settings)\n - AIs will always accept peace so if you do not want to be in war anylonger with a booted player you can just offer the AI peace and it will automatically accept it\n\nMod internal history between turns:\n - All mod interaction is documented between turns in the mod history and gets written into the normal history\n - It is separated in: \n --- public (Accepting peace and depending on settings accepting alliances), it can be seen by anyone \n --- private (sending offers and denying offers and depending on settings accepting alliances), it can only be seen by involved players";
	mods["Advanced Diplo Mod V4"]["How to use"] = {};
	mods["Advanced Diplo Mod V4"]["How to use"]["Essentials"] = "This is a quite big, relatively frequently used mod. I've played with this mod a lot and it is a reliable way to have some sort of forced diplomacy in a game. Before we go in deeper how to use this mod, there are some key details you need to know.\n\nFirst off, the mod keeps track of your \"relation state\" with other players. There are 3 states you can be in, those are\n - War\n - Peace\n - Alliance \n\nWhen a game starts you'll always be at peace with everyone, there is no way you can attack other players in the first turn.\n\nSecond, some cards can be configured if you can play the cards on players in a specific relation state. Those cards are\n - Bomb card\n - Sanction card\n - Spy card\n - Gift card\n\nThe game creator can configure all these cards differently, so make sure you read the mod settings. Every card configuration is listed perfectly as should be.\n\nThis mod is a menu based mod. All the features and options are in the custom mod menu.";
	mods["Advanced Diplo Mod V4"]["How to use"]["Declaring war"] = "When a game starts, everyone is at peace with each other. This means that any attacks on players in the first turn will get skipped. The only territories you can conquer are that of neutral territories. Players can decide they want to change this and can declare war on a player whenever they like. When you open the mod menu you’ll see some buttons (note that some of the buttons might be interactable and some not, this can change from time to time). Let’s say we want to declare on AI 1. We click the [Declare War] button and end up in the next window. Here we can choose a player if we click / tap the [Select player…] option (note that only the players you’re at peace with will be listed). This will prompt us to choose a player or to cancel the action. After we have chosen the player the value on the  [Declare War] button has been changed to the player name we chose, in this example to AI 1. Now we click on the Declare button and the window will reset after adding an order in our orderlist with the following text: “Declare war on AI 1”. Now we can make the rest of our orders and submit the turn. The player you declared on has no choice in either fight or send you a peace request.\n\nNote that when you submit your orders this “Declare war” order will always be executed as one of the last orders of the turn. This means that you always have to wait to attack the player till the next turn.";
	mods["Advanced Diplo Mod V4"]["How to use"]["Offering peace"] = "When you’re done with a war you can send the other player a peace request. Just follow the exact same path as is listed at declaring war. The main thing that is different compared to declaring war is instead of the players you’re in peace with, only the players you’re in war with will be listed. \n\nWhen you click the button [Offer] your client will send the server a message with the information the mod needs. The server will update the client of the player you send a peace request about the open peace offer. When the player accepts the peace the server will update your client again about it. Note that only when the other player has accepted the peace offer there will be peace, as long as the peace offer is pending the war will still remain.";
	mods["Advanced Diplo Mod V4"]["How to use"]["Offer an alliance"] = "When you want to have an alliance with another player you can send him an alliance request. To do this you can follow the steps listed at declaring war. Note that only players you are at peace with will appear in the list.\n\nWhen you click the button [Offer] your client will send the server a message, same as with a peace offer. The only difference between offering peace and offering an alliance is that when you (either you or the player you’ve sent it to) have a pending alliance offer you can’t attack the other player, while with a pending peace offer you and the other player are still able to attack each other.";
	mods["Advanced Diplo Mod V4"]["How to use"]["Cancelling an alliance"] = "When you have an alliance you can cancel this by following the same steps as listed at declaring war. The alliance cancel will have the same order behavior, it will appear in your order list and always will be one of the last orders. Note that you can’t declare war on a player in the same turn you canceled the alliance between you two. This means that there you will be able to attack a former ally after 2 turns. 1 turn is spent canceling the alliance, the next turn is spent declaring war on that player and thus the third turn is the first turn you two can attack each other.";
	mods["Advanced Diplo Mod V4"]["How to use"]["Mod History"] = "Another feature of this mod is that it keeps track of its history because the alert system doesn’t work that well sometimes. When you click / tap the button [Mod history] you’ll be able to see what will be written to the turn history before everyone has submitted their turn.";
	mods["Advanced Diplo Mod V4"]["How to use"]["Some last notes"] = "AI’s will always accept peace offers. If you are in war with an AI or the player turned AI you can guarantee peace by sending a peace offer to the player / AI. The mod will immediately tell you the peace offer has been accepted.";
	mods["Advanced Diplo Mod V4"]["How to use"]["Player list"] = "I’ll have to admit it, I just found out about this feature while writing this manual xD. If you are on the main menu and scroll down you’ll find a list of your current diplomacy. It will list out every player in their category, depending on your “relation state”.";
	mods["Advanced Diplo Mod V4"]["How to set up"] = {};
	mods["Advanced Diplo Mod V4"]["How to set up"]["AI settings"] = "There are 2 settings you can turn on or off. The “Allow AIs to declare on Player” option makes the AI declare on a player when it borders him. This is sometimes annoying since you’ll have to send the AI a peace request every turn if you don’t want to be in war with the AI. The other option allows AIs to declare on other AIs. Note that most of these wars are ended by elimination since AIs don’t send peace offers. The only way these wars end is by one of the players returning from the game after a boot / surrender and sending a peace request."
	mods["Advanced Diplo Mod V4"]["How to set up"]["Alliance settings"] = "With the first option you can remove the alliance system from the mod. Players will not be able to send and accept alliance requests if this option is enabled.\n\nWith the other 2 options the spy card has to be enabled to do something, since the mod will automatically play a spy card on everyone you’re allied with (or even on those players that are allied to your allies)";
	mods["Advanced Diplo Mod V4"]["How to set up"]["Card Settings"] = "4 cards can be configured to be played on players where you have a certain “relation state” with. These cards are the sanctions card, bomb card, spy card and gift card. Note if you disable all 3 options of a card it can never be played on anyone, not even yourself.";
	mods["Advanced Diplo Mod V4"]["How to set up"]["Other Settings"] = "The last setting requires a spy card to be enabled in the game since it will allow you to see everyone you’re at peace with.";
	mods["Advanced Diplo Mod V4"]["Bugs"] = bugFreeMessage;
	mods["Advanced Diplo Mod V4"]["Compatibility"] = "Not compatible with other diplomacy mods:\n - Diplomacy\n - Diplomacy 2";
	-- AI's don't deploy
	-- Buy Cards
	-- Commerce Plus
	-- Custom Card Package
	-- Diplomacy 2
	-- Late Airlifts
	-- Limited Attacks
	mods["Limited Multiattacks"] = {};
	mods["Limited Multiattacks"]["Mod description"] = "";
	mods["Limited Multiattacks"]["How to use"] = "";
	mods["Limited Multiattacks"]["How to set up"] = "";
	mods["Limited Multiattacks"]["Bugs"] = "";
	mods["Limited Multiattacks"]["Compatibility"] = "";
	-- Neutral Moves
	-- Safe Start
	-- Swap territories
	-- Take Turns
	mods["AI's don't play cards"] = {};
	mods["AI's don't play cards"]["Mod description"] = "";
	mods["AI's don't play cards"]["How to use"] = "";
	mods["AI's don't play cards"]["How to set up"] = "";
	mods["AI's don't play cards"]["Bugs"] = "";
	mods["AI's don't play cards"]["Compatibility"] = "";
	-- Better don't fail an attack
	-- Bonus Airlift
	-- BonusValue QuickOverrider
	-- Connected Commanders
	-- Deployment Limit
	-- Don't lose a territory
	-- Extended Randomized bonuses
	-- Extended Winning Conditions
	-- Forts
	-- Gift Armies 2
	mods["Hybrid Distribution"] = {};
	mods["Hybrid Distribution"]["Mod description"] = "";
	mods["Hybrid Distribution"]["How to use"] = "";
	mods["Hybrid Distribution"]["How to set up"] = "";
	mods["Hybrid Distribution"]["Bugs"] = "";
	mods["Hybrid Distribution"]["Compatibility"] = "";	
	mods["Hybrid Distribution 2"] = {};
	mods["Hybrid Distribution 2"]["Mod description"] = "";
	mods["Hybrid Distribution 2"]["How to use"] = "";
	mods["Hybrid Distribution 2"]["How to set up"] = "";
	mods["Hybrid Distribution 2"]["Bugs"] = "";
	mods["Hybrid Distribution 2"]["Compatibility"] = "";
	-- Information for spectators
	-- King of the Hills
	-- Lotto Mod -> Instant Random Winner
	-- More_Distributions
	-- One Way Connections
	-- Random Starting Cities
	-- Runtime Wastelands
	-- Spawnbarriers
	mods["Special units are Medics"] = {};
	mods["Special units are Medics"]["Mod description"] = "";
	mods["Special units are Medics"]["How to use"] = "";
	mods["Special units are Medics"]["How to set up"] = "";
	mods["Special units are Medics"]["Bugs"] = "";
	mods["Special units are Medics"]["Compatibility"] = "";
	-- Stack Limit
	-- Transport Only Airlift
end