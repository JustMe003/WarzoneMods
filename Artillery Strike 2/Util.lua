require("DataConverter");

PREFIX_AS2 = "AS2";
SEPARATOR_AS2 = "_";
GROUP_SEPARATOR_AS2 = "|";

BUY_ARTILLERY = "Buy";
ARTILLERY_STRIKE = "Strike";

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

function isArtillery(sp)
   if sp.proxyType ~= "CustomSpecialUnit" then return false; end
   for _, art in pairs(Mod.Settings.Artillery) do
      if art.Name == sp.Name then return true; end
   end
   return false;
end

function nameToArtilleryID(name)
   for _, art in pairs(Mod.Settings.Artillery) do
      if art.Name == name then return art.ID end
   end
end

function countArtilleryOfType(standing, name, p, countOrders)
    countOrders = countOrders or false;
    local c = 0;
    for _, terr in pairs(standing) do
        if terr.OwnerPlayerID == p and #terr.NumArmies.SpecialUnits > 0 then
            for _, sp in ipairs(terr.NumArmies.SpecialUnits) do
                if isArtillery(sp) and sp.Name == name then
                    c = c + 1;
                end
            end
        end
    end
    if countOrders then
        local unitID = -1;
        for _, art in ipairs(Mod.Settings.Artillery) do
            if art.Name == name then 
                unitID = art.ID; 
                break; 
            end
        end
        for _, order in ipairs(Game.Orders) do
            if order.proxyType == "GameOrderCustom" and string.sub(order.Payload, 1, #(PREFIX_AS2 .. SEPARATOR_AS2 .. BUY_ARTILLERY)) == PREFIX_AS2 .. SEPARATOR_AS2 .. BUY_ARTILLERY then
                local splits = split(order.Payload, SEPARATOR_AS2);
                local type = tonumber(splits[3]);
                if type ~= nil and type == unitID then c = c + 1; end
            end
        end
    end
    return c;
end

function tableIsEmpty(t)
   for _, _ in pairs(t) do return false; end
   return true;
end

function getDistanceBetweenTerrs(terrs, t1, t2, limit)
    if t1 == t2 then return 0; end
    local flaggedTerrs = {t1.ID};
    local nextTable = {t1.ConnectedTo};
    local length = 1;
    while length <= limit do
        local t = {};
        for _, conns in ipairs(nextTable) do
            for connID, _ in pairs(conns) do
                if connID == t2.ID then
                    return length;
                end
                if not valueInTable(flaggedTerrs, connID) then
                    table.insert(flaggedTerrs, connID);
                    table.insert(t, terrs[connID].ConnectedTo);
                end
            end
        end
        nextTable = t;
        length = length + 1;
    end
    return length;
end

function valueInTable(t, v)
    for _, v2 in pairs(t) do
        if v == v2 then return true; end
    end
    return false;
end

---Rounds and returns a number to a certain number of decimals
---@param n number # the number to be rounded
---@param dec integer? # The amount of decimals after the dot, default is 0
---@return number | integer # Returns the rounded number
function round(n, dec)
    local mult = 10^(dec or 0)
    return math.floor(n * mult + 0.5) / mult
end

function addSIfMultiple(n)
    if n > 2 or n == 0 then return "s"; end
    return "";
end

function createInfoButton(par, txt)
    CreateButton(par).SetText("?").SetColor(colors["Royal Blue"]).SetOnClick(function()
        UI.Alert(txt);
    end)
end

function getTableLength(t)
    local c = 0;
    for _, _ in pairs(t) do c = c + 1; end
    return c;
end

function createArtillery(art, p, reloadTurn)
    local builder = WL.CustomSpecialUnitBuilder.Create(p);
    builder.ImageFilename = "Artillery_" .. art.ColorName .. ".png";
    builder.Name = art.Name;
    builder.IsVisibleToAllPlayers = art.IsVisibleToAllPlayers;
    builder.CanBeAirliftedToSelf = art.CanBeAirliftedToSelf;
    builder.CanBeGiftedWithGiftCard = art.CanBeGiftedWithGiftCard;
    builder.CanBeTransferredToTeammate = art.CanBeTransferredToTeammate;
    builder.CanBeAirliftedToTeammate = builder.CanBeAirliftedToSelf and builder.CanBeTransferredToTeammate;
    builder.IncludeABeforeName = art.IncludeABeforeName;
    builder.AttackPower = art.AttackPower;
    builder.AttackPowerPercentage = math.max(0, art.AttackPowerPercentage / 100) + 1;
    builder.DefensePowerPercentage = math.max(0, art.DefensePowerPercentage / 100) + 1;
    builder.CombatOrder = art.CombatOrder + 6971;
    if art.UseHealth then
        builder.Health = art.Health;
        if art.DynamicDefencePower then
            builder.DefensePower = art.Health;
        else
            builder.DefensePower = art.DefensePower;
        end
    else
        builder.DamageAbsorbedWhenAttacked = art.DamageAbsorbedWhenAttacked;
        builder.DamageToKill = art.DamageToKill;
        builder.DefensePower = art.DefensePower;
    end
    builder.ModData = DataConverter.DataToString(getModDataTable(reloadTurn or 0, art.ID), Mod);

    return builder.Build();
end

function getModDataTable(reloadTurn, artID)
    return {
        AS2 = {
            ReloadTurn = reloadTurn, 
            TypeID = artID
        }, 
        Essentials = {
            UnitDescription = "This unit can target a territory and deal damage to distant territories. Check the full settings page to see my full details"
        }
    };
end
