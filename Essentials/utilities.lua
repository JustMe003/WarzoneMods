function getMods()
	return {"Buy Neutral", "Diplomacy", "Gift Armies", "Gift Gold", "Picks Swap", "Randomized Bonuses", "Randomized Wastelands", "Advanced Diplo Mod V4", "AIs don't deploy", "Buy Cards", "Commerce Plus", "Custom Card Package", "Diplomacy 2", "Late Airlifts", "Limited Attacks", "Limited Multiattacks", "Neutral Moves", "Safe Start", "Swap Territories", "Take Turns", "AI's don't play cards", "Better don't fail an attack", "Bonus Airlift", "BonusValue QuickOverrider", "Connected Commanders", "Deployment Limit", "Don't lose a territory", "Extended Randomized Bonuses", "Extended Winning Conditions", "Forts", "Gift Armies 2", "Hybrid Distribution", "Hybrid Distribution 2", "Infromations for spectaters", "King of the Hills", "Local Deployment Helper", "Lotto Mod -> Instant Random Winner", "More_Distributions", "One Way Connections", "Press This Button", "Random Starting Cities", "Runtime Wastelands", "Spawnbarriers", "Special units are Medics", "Stack Limit", "Transport Only Airlift"}
end

function getStatus(mod)
	local index;
	for i, v in pairs(getMods()) do if mod == v then index = i; break; end end
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
		if ret == nil then return nil; end
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

function getTableLength(t)
	local count = 0;
	for i, _ in pairs(t) do
		count = count + 1;
	end
	return count;
end


function getBugs()
	local t = {};
	for i, _ in pairs(mods) do
		t[i] = mods[i]["Bugs"];
	end
	return t;
end

function getBugFreeMessage()
	return "This mod is bug free as far as I know. If you do find a bug please send the mod creator or me a message with the following:\n -  A description of the bug\n -  The link to the game\n\nJust_A_Dutchman_: (https://www.warzone.com/Discussion/SendMail?PlayerID=1311724)";
end

function initManuals()
	local bugFreeMessage = getBugFreeMessage();
	local compatibilityAllMessage = "This mod can be used with every other mod / setting in Warzone. If you do find something please send me a message with the following:\n -  A description of what happened or should have happened\n -  The link to the game\n - The turn number where it happened\n\nJust_A_Dutchman_: (https://www.warzone.com/Discussion/SendMail?PlayerID=1311724)";
	mods = {};
	mods["Buy Neutral"] = {};
	mods["Buy Neutral"]["Mod description"] = "Allows players to purchase neutral territories with gold rather than conquering them by force. Requires that the game is a commerce game, and will do nothing otherwise. \n\nThe game creator can configure how expensive territories are to purchase, based on how many armies are on the neutral territory. To initiate a purchase, click the button for the mod on the menu, select the territory, and a purchase order will be inserted into your orders list. The purchase will complete when the turn advances.";
	mods["Buy Neutral"]["How to use"] = "This mod allows players to buy neutral territories with gold, the price of the territory is determined by the amount of armies and the multiplier configured by the game creator.\n\nThere are some things you should know before you start asking questions. The most notable thing you should know is that only territories you can fully see are purchasable. When playing with light or dense (also heavy) fog you will be able to see who owns the territory, but not the army count and which special units. The mod sees this as ‘not fully’ visible’ and these territories are not purchasable. To buy a territory in light, dense or heavy fog that is not fully visible, you should play a reconnaissance, surveillance or spy (only if you’re able to spy on neutral) card.\n\nSecond, when you add the order to buy a territory does not mean you will buy the territory for sure. When the turn advances, the mod will look at every purchase order and check if the territory is still neutral. If the territory is not neutral anymore at the time your purchase order gets processed, nothing will happen. Note that the purchase order type is GameOrderCustom, you can put these orders wherever you want in your order list. You can even put them before your deployment orders where they will get processed before any deployment orders, even those of your opponents.\n\nThird, the amount of armies on the neutral territory can differ at the time your purchase order gets processed then when you added the order in your order list. If the amount of armies on the territory is more than you originally paid for your purchase will get canceled. If the amount of armies is less than you originally paid for and the territory is still neutral, you will buy the territory but won’t get any compensation for paying too much.\n\nAt last, when playing on a big map, with a lot of neutral territories and no fog, the list where you can choose the territories from will be really, really big. Creating the list will take a while and searching for a precise territory is a task which requires a lot of patience. In this case I strongly recommend using the browser version to submit your turn. You can use [ctrl] + [F] to search for the name of the territory in the list which is way easier and faster than looking at every possible territory in the list. Note you cannot add these orders in the browser and finish creating your orders on mobile or in the app since the purchase orders will not be stored on the browser. The other way around is possible though.";
	mods["Buy Neutral"]["How to set up"] = "When you add this mod you have to make sure you enable commerce, otherwise the mod won’t do anything and players won’t be able to create purchase orders at all.\n\nAlso be careful with the multiplier. When you set the multiplier to high, buying neutrals will get extremely inefficiënt but setting it to low, it becomes extremely efficiënt. The bare minimum in my opinion is 1, although it is possible to set it to 0. But by doing so you will give players the possibility to buy every territory they can fully see for free, resulting in a massive auction where the players who know what is listed above (how to use) will get a massive advantage.";
	mods["Buy Neutral"]["Bugs"] = bugFreeMessage;
	mods["Buy Neutral"]["Compatibility"] = "This mod is compatible with every setting, but does need the game to be a commerce game to allow the mod to be actually used. Nevertheless this mod lacks some useful features and really needs an update or revamp.";
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
	mods["Custom Card Package"] = {};
	mods["Custom Card Package"]["Bugs"] = "When a nuke is played the first attack / transfer gets skipped and added back when all the nukes have been played. This results in the fact that the player who has first move will have 2 attacks / transfers before any other attacks / transfers have been played."
	-- Diplomacy 2
	-- Late Airlifts
	-- Limited Attacks
	mods["Limited Multiattacks"] = {};
	mods["Limited Multiattacks"]["Mod description"] = "This mod allows you to limit the attack range of multiattack. Furthermore, you can bind it to cards";
	mods["Limited Multiattacks"]["How to use"] = "It is quite important to check up on the mod settings when a game uses this mod. There are 2 settings you have to know to use multi attack properly:\n - Is multi attack bound to a card or multiple cards?\n - What is the limit of a multi attack chain?\n\nWhen multi attack is bound to a card or multiple cards the effect of multi attack is only enabled when you’ve played one of those cards. If multi attack is bound to the reinforcement card you’ll only be able to use multi attack if you played the reinforcement card. If it is bound to multiple cards (say spy card and gift card) you’ll only have to play 1 of (either) those cards, not both to enable multi attack. Note that multi attack is only enabled for you if you played the card, if other players want to have multi attack too they too have to play a card that enables it.\n\nIf you enable multi attack (or when it is always enabled) you still have to watch out for the limit of multi attacks. The mod keeps track of how many attacks armies have made so when they reach the limit the attacks are canceled, most of the time breaking your normal multi attack chain (an attack gets skipped, and all other attacks in the chain won’t go through since you don’t own the attacking territory) and leads to confusion for most players.\n\nWhen the limit of multi attacks is not set to 0 (0 is infinite multi attacks, currently not possible: see bugs) attacks after the limit reached will be canceled. If the limit is set to 5, you’re able to make 1 attack as you normally do in every warzone game and pre-route 4 other attacks using the same armies. If you make one more pre-routed attack it will get canceled, leading that (if there are even more) attacks after the canceled attack won’t happen as you would imagine since you don’t own the attacking territory at the time the order is happening.\n\nNote that when armies make a transfer they are completely stuck for the rest of the turn. This is the case in every Warzone game. it is not (yet) possible to cancel this, even in normal multi attack games.";
	mods["Limited Multiattacks"]["Smart expansion"] = "Because this mod can have a limit of multi attacks you sometimes can’t create 1 long attack chain to capture as many territories as you can. When you want to capture as many territories as possible you should create multiple little attack chains (with the maximum length equal to the limit of multi attacks allowed) with exactly enough armies to capture every territory on the way.\n\nThis mod has a feature included that let you calculate the exact amount of armies you have to send away. You can find it in the extra section if this mod is included or if multi attack is enabled";
	mods["Limited Multiattacks"]["How to set up"] = " - You don’t need to enable multi attack yourself, the mod will override this setting.\n - You can specify what the limit of multi attacks will be (see bugs for an ongoing issue). This value can be set to any number between 0 and 100.000.\n - To make the multi attacks behave like a normal Warzone game with multi attack you should keep the option on. If you keep the option off every failed attack will freeze the remaining armies on the territory the attack was from, canceling all attacks / transfers from this territory.\n - The remaining checkboxes are for binding multi attack to a card or cards. Check the boxes of the corresponding cards you want, if you want multi attack to be bound to a card or cards. If you don’t want multi attack to be bound to a card or cards, leave all the checkboxes unchecked.";
	mods["Limited Multiattacks"]["Bugs"] = " - (Bug solved) When transferring to a territory all attack / transfer orders from the receiving territory gets canceled. Imagine some territories connected to each other. For simplicity we’ll use the alphabet as their names. You own territory A, the other territories (B, C and D) are neutral. Your first order is to attack B from A. Your second order is a pre-routed transfer from B back to A. Thereafter you (multi) attack territories C and D starting from A. The order list would look like this:\n - ? armies from A will attack/transfer B\n - ? armies from B will attack/transfer A\n - ? armies from A will attack/transfer C\n - ? armies from C will attack/transfer D\n\n The first 2 orders will execute without any interferrence as its supposed to, but since the second order is a transfer it would freeze all the armies at A, so the 3 order would get skipped. Because of this the 4th order would also be skipped since we don't control C\n\n - (bugfix in review) Currently it is not yet possible to set the limit of multi attack to 0, although the UI does tell you it is. Trying to do this results in an alert telling you it is not possible, and even if the value goes through it gets overwritten to 1. If you want to have unlimited multi attacks (most usable in combination with enabling it with cards) you can set it to 100.000, which is technically infinite multi attacks";
	mods["Limited Multiattacks"]["Compatibility"] = compatibilityAllMessage;
	-- Neutral Moves
	-- Safe Start
	-- Swap territories
	-- Take Turns
	mods["AI's don't play cards"] = {};
	mods["AI's don't play cards"]["Mod description"] = "Prevents AI's from playing cards, configurable for all (except reinforcement) cards AI's play. Note that checking a checkbox allows an AI to play that card";
	mods["AI's don't play cards"]["How to use"] = "This mod prevents AI from playing cards. It simply checks every order in the order list when a turn gets processed. When the mod finds a card being played by an AI, it checks if the AI is allowed to play the card (configurable in the mod configuration) and cancels the order if the AI is not allowed to play it. If a player gets booted but returns it will find (unless the AI decided to discard some cards) all his cards untouched.";
	mods["AI's don't play cards"]["How to set up"] = "When adding the mod to the game you’ll get the mod configuration. Here you’re able to specify for each AI playable card if AIs are allowed to play the card or not. Note that when adding the mod all the settings are on their default False value, when you want AIs to play a certain card (eg. the blockade card) you should tick the corresponding checkbox which will allow the AIs to play that card.\n\nThese 5 cards AIs play can be configured:\n - Blockade card\n - Emergency blockade card\n - Sanction card\n - Diplomacy card\n - \n\nNote that AIs always play reinforcement cards, but canceling this is way more difficult due to the way warzone handles these cards (see Bugs below).";
	mods["AI's don't play cards"]["Bugs"] = "This isn’t really a bug, but it did make the mod behave differently than I expected. Since the effect of a reinforcement card goes into play immediately after playing it can not be canceled. Doing so will result in the effect going through and the AI keeping the card, meaning the AI would be able to play the card again next turn with the same thing happening.";
	mods["AI's don't play cards"]["Compatibility"] = compatibilityAllMessage;
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
	mods["Hybrid Distribution"]["Mod description"] = "Allows for some territories to be auto-distributed and some to be manual-distributed (picked).";
	mods["Hybrid Distribution"]["How to use"] = "Normally you would have either an automatic distribution (get random territories) or a manual distribution where you could specify an order of picks to allow you to set yourself up. This mod combines the two, resulting in a ‘hybrid’ distribution.\n\nThe game creator can specify how many territories everyone gets before the distribution phase. You will have at least one territory on the map and everyone can see this. You can also see everyone else their auto-distributed territories so you can use this information in the distribution phase.";
	mods["Hybrid Distribution"]["How to set up"] = "This mod only has one setting, the number of auto-distributed territories. There are a few notes though.\n - You have to set the game to manual distribution yourself, the mod doesn’t overwrite this setting and the mod will do nothing if the game uses automatic distribution\n - The mod will auto distribute territories from neutrals, leaving the pickable territories. Note that playing with full distribution and no wastelands the mod will not auto-distribute territories and note that when playing with full distribution and wastelands enabled the mod will only auto-distribute wastelands.\n - The mod will not overwrite the number of armies on the territories, so this would be equal to the number of armies in neutrals not in the distribution. Note that when playing with wastelands these army numbers don’t change. Players can end up with a wasteland, keeping the amount of armies.\n\nIf you’re looking to avoid one of these, you should use Hybrid Distribution 2";
	mods["Hybrid Distribution"]["Bugs"] = "Not really a bug, but a good feature to point out.\n\nThe mod does not overwrite the number of armies on the territory when auto-distributing. This will normally result in the auto-distributed territories having the same amount of armies the neutrals (not in the distribution) have, but when wastelands are enabled it can result in a player getting a wasteland. This can lead to unfair advantages / disadvantages. To play with wastelands and hybrid distribution I recommend using Hybrid Distribution 2 which does overwrite the number of armies.";
	mods["Hybrid Distribution"]["Compatibility"] = compatibilityAllMessage;	
	mods["Hybrid Distribution 2"] = {};
	mods["Hybrid Distribution 2"]["Mod description"] = "Allows for some territories to be auto-distributed and some to be manual-distributed (picked) with more options.\n - Choose if territories in the distribution or neutrals are auto-distributed\n - Choose if auto-distributed territories have the same amount of armies as manual-distributed territories or as neutrals not in the distribution\n - This mod overwrites wastelands, 'Hybrid Distribution' does not. This can lead to players having wastelands and thus more or less armies than their opponent\n - Forces the game to be manual distribution since the mod does nothing with auto distribution";
	mods["Hybrid Distribution 2"]["How to use"] = "The Hybrid Distribution 2 does the same thing as Hybrid Distribution but has more options and better compatibility.\n\nNormally you would have either an automatic distribution (get random territories) or a manual distribution where you could specify an order of picks to allow you to set yourself up. This mod combines the two, resulting in a ‘hybrid’ distribution.\n\nThe game creator can specify how many territories everyone gets before the distribution phase. You will have at least one territory on the map and everyone can see this. You can also see everyone else their auto-distributed territories so you can use this information in the distribution phase.";
	mods["Hybrid Distribution 2"]["How to set up"] = "The mod has 3 options, with one being similar to Hybrid Distribution. You’ll have to specify how many territories each player gets auto-distributed before the distribution phase. The other 2 options let you control which territories are auto-distributed and how many armies should be on those territories.\n\nThe second setting is a checkbox, which lets you control if the territories in the distribution are auto-distributed or neutrals (including wastelands, they get overwritten). The third option is also a checkbox and lets you specify what the amount of armies on the auto-distributed territories should be. Leaving this option checked will result in those territories having the same amount of armies as manual-distributed territories, unchecking this option will result in the same behavior as Hybrid Distribution except for the fact this mod does override wastelands.";
	mods["Hybrid Distribution 2"]["Bugs"] = bugFreeMessage;
	mods["Hybrid Distribution 2"]["Compatibility"] = compatibilityAllMessage;
	-- Information for spectators
	-- King of the Hills
	-- Lotto Mod -> Instant Random Winner
	-- More_Distributions
	-- One Way Connections
	mods["Press This Button"] = {};
	mods["Press This Button"]["Mod description"] = "This mod adds a button that will reduce the next turn's income of a player by X% if they do not press the button in their current turn. AI's will not be affected by this mod. Once the game started, you can find the button under Game > Press This Button";
	mods["Press This Button"]["How to use"] = "This mod adds something like a dead man’s button to the game, with a punishment if the player does not push the button in time for the next turn. If you succeed in pushing the button, nothing will happen. If you fail to push the button, then your income will get adjusted downwards by a certain percentage. The button can be found in the mod menu. It's big, red and hard to miss :)";
	mods["Press This Button"]["How to set up"] = "There are 2 configurable options. The first option is the percentage of income the player will lose when the player fails to hit the button in time. This number can be anywhere between 1 and 100 percent.\n\nThe second option is to allow the mod to warn the player when they have failed to push the button the previous turn. Unchecking this checkbox won’t send out an alert to the player when they fail to push the button.";
	mods["Press This Button"]["Bugs"] = bugFreeMessage;
	mods["Press This Button"]["Compatibility"] = compatibilityAllMessage;
	-- Random Starting Cities
	-- Runtime Wastelands
	-- Spawnbarriers
	mods["Special units are Medics"] = {};
	mods["Special units are Medics"]["Mod description"] = "This Mod allows special units to revive 100% of the lost armies in the territories connected to the special units. The effect won't work if they are killed by a bomb card or if a special unit is involved in any way in the attack (including if the attack comes from a territoy with a special unit.)";
	mods["Special units are Medics"]["How to use"] = "This mod is relatively simple and allows you to do some crazy stuff, things like generating armies while you’re expanding or defend twice with armies while defending. But when you want to use these methods you do need to know when your armies get revived. There are 2 scenarios where the mod will revive your lost armies back:\n - You defend against a player / AI while both defending and attacking territory don’t contain a special unit\n - You attack anyone (neutral, AI, a player) and (one of) your special unit(s) is next to the defending territory, but not on the attacking territory.\n\nIf these scenarios above are a bit difficult to understand, just know that whenever a special unit is involved in the attack your armies won’t get revived. Note that so far of all the special units only the commander is available for use, the four bosses can be made available for Warzone multiplayer and custom single player games but there is yet a mod to be made for it. ";
	mods["Special units are Medics"]["How to set up"] = "There are no options on this mod, but to make the mod actually do something you’ll need to include special units in your game. So far the only special unit is the commander, the four bosses are available for mods but are not yet included in any.";
	mods["Special units are Medics"]["Bugs"] = bugFreeMessage;
	mods["Special units are Medics"]["Compatibility"] = compatibilityAllMessage;
	-- Stack Limit
	-- Transport Only Airlift
end

function initCompatibility()
	comp = {};
	comp["Late Airlifts"] = {};
	comp["Connected Commanders"] = {};
	comp["Late Airlifts"]["Connected Commanders"] = {};
	comp["Late Airlifts"]["Connected Commanders"].Occurance = "rare";
	comp["Late Airlifts"]["Connected Commanders"].Message = "There are a lot of requirements for the mod interference to occur, but when they it occurs the event player will not like it...\n\nPlease read more about this mod interference under [compatibility] to be sure you want both these mods into the game";
	comp["Connected Commanders"]["Late Airlifts"] = {};
	comp["Connected Commanders"]["Late Airlifts"].Occurance = "rare";
	comp["Connected Commanders"]["Late Airlifts"].Message = "There are a lot of requirements for the mod interference to occur, but when they it occurs the event player will not like it...\n\nPlease read more about this mod interference under [compatibility] to be sure you want both these mods into the game";
end

function checkModInterference(mod1, mod2)
	if comp == nil then return false; end
	if comp[mod1] ~= nil then
		if mod2 == nil then return true; end
		if comp[mod1][mod2] ~= nil then
			return comp[mod1][mod2];
		end
	end
	return false;
end