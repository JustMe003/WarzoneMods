function forcedRulesInit(func)
    func_JAD = func;
    forcedRules()
end

function forcedRules()
    local win = "forcedRulesMain";
    destroyWindow(getCurrentWindow());
    if windowExists(win) then
        resetWindow(win);
    end
    window(win);
    local vert = newVerticalGroup("Vert", "root");
    newLabel(win .. "expl", vert, "In order to not have a screen filled with text I've divided the rules up into sections. Pick a topic to get to know more about it", "#CCCCCC");
    newButton(win .. "Diplomacy", vert, "Diplomacy", showDiplomacyRules, "Royal Blue");
    newButton(win .. "Factions", vert, "Factions", showFactionRules, "Royal Blue");
    newButton(win .. "Joins", vert, "Faction joins", showFactionJoinRules, "Royal Blue");
    newButton(win .. "wars", vert, "Faction wars", showFactionsWarRules, "Royal Blue");
    newButton(win .. "Return", vert, "Return", func_JAD, "Orange");
end

function showDiplomacyRules()
    local win = "forcedRulesMain";
    destroyWindow(getCurrentWindow());
    if windowExists(win) then
        resetWindow(win);
    end
    window(win);
    local vert = newVerticalGroup("Vert", "root");
    newLabel(win .. "text", vert, "Most diplomacy mods skip illegal orders, like attacks on players which whom you have an alliance. The Factions mod does this differently, it uses Diplomacy cards to get to the same point. The cards are automatically played all the way at the end of the turn with the exception of some occurrences. This might occur if you just established peace with another players or multiple", "#CCCCCC");
    newButton(win .. "Return", vert, "Return", forcedRules, "Orange");

end

function showFactionRules()
    local win = "forcedRulesFactions";
    destroyWindow(getCurrentWindow());
    if windowExists(win) then
        resetWindow(win);
    end
    window(win);
    local vert = newVerticalGroup("Vert", "root");
    newLabel(win .. "text", vert, "A Faction is simply a group of players in an alliance. Being in a Faction allows you to chat with all your Faction members and declare war on another Faction. A Faction always have 1 Faction leader, this player has all the power to allow new players to join, kick players, declare war on other Factions, offering / accepting peace and setting another player as Faction leader\n\nYou are allowed to join as many Factions as you like, but be wary of the consequences. Any Faction can force you to declare war on other players and can force Faction leaders to kick you (see Faction wars)", "#CCCCCC");
    newButton(win .. "Return", vert, "Return",  forcedRules, "Orange");
end

function showFactionsWarRules()
    local win = "forcedRulesFactionsWar";
    destroyWindow(getCurrentWindow());
    if windowExists(win) then
        resetWindow(win);
    end
    window(win);
    local vert = newVerticalGroup("Vert", "root");
    newLabel(win .. "text", vert, "Besides having 'personal relations' with players, any Faction has 'relations' with other Factions. Factions can either be at war or can be in peace with another Faction. Only Faction leaders can change this relation state.\n\nWhen a Faction declares war on another Faction, the mod takes the following actions:\nFirst, the mod checks if there are players that are in both Factions. The Factions mod does not allow players in 2 Factions that are at war with each other, so players in both Factions are forced to be kicked FROM THE FACTION THAT DECLARED WAR. The way you can look at it is that those players committed treason being in the other Faction too\nBesides checking if players are in the 2 Factions going to war, it will also check for every player if they are in other Factions. If a player is in another Faction and in that same Faction is a member of the other Faction then they are both kicked, with the exception of when one of these players is the Faction leader. You can see this as if all the other Factions do not want to pick a side and therefore kick all players in that war.\nFor example, imagine having 3 Factions in your game, A, B and C. A declares war on B, then every player both in Faction A and B is kicked from A (treason). If one or more players of Faction A is in Faction C and one or more players of Faction B is in Faction C, then all these players will be kicked from C with the exception of when one of these players is the Faction leader of C", "#CCCCCC");
    newButton(win .. "Return", vert, "Return", forcedRules, "Orange");
end

function showFactionJoinRules()
    local win = "forcedRulesFactionJoins";
    destroyWindow(getCurrentWindow());
    if windowExists(win) then
        resetWindow(win);
    end
    window(win);
    local vert = newVerticalGroup("Vert", "root");
    newLabel(win .. "text", vert, "Depending on the setting when clicking the join button for a Faction you actually join the Faction or send a join request to its Faction leader. But you cannot join every Faction, here is the following points where the mod looks at before letting you join.\n\nYou cannot join a Faction if you're at war with one of its members. If you do want to join the Faction, you must first make sure you're at least in peace with all its members.\nIf the setting 'Fair Factions' is on, then you're not allowed to join a Faction when your income + the income of all members combined is bigger than a certain percentage of the total income of all players. This can be used to avoid the best players in the game to team up against all the others", "#CCCCCC");
    newButton(win .. "Return", vert, "Return", forcedRules, "Orange");
end