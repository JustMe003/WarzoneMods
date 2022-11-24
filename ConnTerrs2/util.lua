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

function getAmountOfUnits(playerTerrs)
   if not Mod.Settings.NUnitsIsNTerrs then
      return Mod.Settings.NumberOfUnits; 
   end
   local min = 10000;
   for _, t in pairs(playerTerrs) do
      if #t < min then min = #t; end
   end
   return math.min(min, 5);
end

function buildUnit(p)
   local builder = WL.CustomSpecialUnitBuilder.Create(p);
   builder.Name = "Link";
   builder.AttackPower = 1;
   builder.CanBeAirliftedToSelf = Mod.Settings.CanBeAirliftedToSelf;
   builder.CanBeAirliftedToTeammate = Mod.Settings.TeamsCountAsOnePlayer and Mod.Settings.CanBeAirliftedToSelf;
   builder.CanBeGiftedWithGiftCard = false;
   builder.CanBeTransferredToTeammate = Mod.Settings.TeamsCountAsOnePlayer;
   builder.CombatOrder = 9121;
   builder.DamageAbsorbedWhenAttacked = 1;
   builder.DamageToKill = 1;
   builder.DefensePower = 1;
   builder.ImageFilename = "Link.png";
   builder.IncludeABeforeName = true;
   builder.TextOverHeadOpt = "Link";
   return builder.Build();
end