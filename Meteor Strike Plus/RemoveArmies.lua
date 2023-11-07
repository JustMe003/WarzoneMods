--  This function will return a WL.TerritoryModification and removes armies from the given territory, just like it was attacked
--	This function will turn the territory neutral when it has no armies or special units left
--	Modified to the needs of the Meteor Strike Plus mod
--	
--
--  Inputs:
--      terr            [Territory]     The event territory. The function will only remove armies from this territory
--      damage          [Integer]       The amount of damage the territory takes (pass a 0 to remove all armies and units and turn the territory neutral)
--
--	Output:
--		mod				[WL.TerritoryModification]		

function removeArmies(terr, damage)
	local mod = WL.TerritoryModification.Create(terr.ID);
	if damage == 0 or killsAllArmies(terr.NumArmies, damage) then
		mod.AddArmies = -terr.NumArmies.NumArmies;
		local t = {};
		for _, sp in ipairs(terr.NumArmies.SpecialUnits) do
			table.insert(t, sp.ID);
		end
		if #t ~= 0 then
			mod.RemoveSpecialUnitsOpt = t;
		end
		mod.SetOwnerOpt = WL.PlayerID.Neutral;
	else
		local spInOrder = {};
		for _, sp in ipairs(terr.NumArmies.SpecialUnits) do
			local co = sp.CombatOrder
			local b = false;
			for i, sp2 in ipairs(spInOrder) do
				if sp2.CombatOrder > co then
					table.insert(spInOrder, i, sp);
					b = true;
					break;
				end
			end
			if not b then
				table.insert(spInOrder, sp);
			end
		end
		
		local processedArmies = false;
		local t = {};

		for _, sp in ipairs(spInOrder) do
			if not processedArmies and sp.CombatOrder >= 0 then
				mod.AddArmies = math.max(-damage, -terr.NumArmies.NumArmies);
				damage = damage - terr.NumArmies.NumArmies;
				processedArmies = true;
				if damage <= 0 then
					break;
				end
			end
			if getHealth(sp) <= damage then
				table.insert(t, sp.ID);
			elseif unitHasHealth(sp) and not unitIsAlien(sp) then
				table.insert(t, sp.ID);
				mod.AddSpecialUnits = {getClone(sp, damage)}
			end
			
			damage = damage - getHealth(sp);
			if not unitHasHealth(sp) and sp.proxyType == "CustomSpecialUnit" and sp.DamageAbsorbedWhenAttacked ~= nil then
				damage = damage - sp.DamageAbsorbedWhenAttacked;
			end
			
			if damage <= 0 then
				break;
			end
		end

		if not processedArmies then
			mod.AddArmies = math.max(-damage, -terr.NumArmies.NumArmies);
		end
		
		if #t ~= 0 then
			mod.RemoveSpecialUnitsOpt = t;
		end
	end
	return mod;
end

--	function that checks whether the damage is enough to kill all the units
--
--	Inputs
--		armies			[Armies]			The Armies object that will receive the damage
--		damage			[Number]			The damage that will be inflicted on the units
--	Output
--		Boolean			[Boolean]			True if the damage is enough to kill all the armies, false if some units survive

function killsAllArmies(armies, damage)
	print(armies);
	damage = damage - armies.NumArmies;
	for _, sp in ipairs(armies.SpecialUnits) do
		if damage < 0 then return false; end
		damage = damage - getHealth(sp);
		if sp.proxyType == "CustomSpecialUnit" and not unitHasHealth(sp) and sp.DamageAbsorbedWhenAttacked ~= nil then
			damage = damage - sp.DamageAbsorbedWhenAttacked;
		end
	end
	return damage >= 0;
end

--	Clone the passed special unit (only if it has [Health] instead of [DamageAbsorbedWhenAttacked])
--	It will subtract the passed damage and return a the new special unit (with updated Health)
--	This function should not be called elsewhere, and if you, do not call it when the unit should die
--
--	Inputs:
--		sp			[CustomSpecialUnit]			The unit to be modified
--		damage		[Integer]					The damage that will get subtracted from it's health
--
--	Output:
--		copy		[CustomSpecialUnit]			The updated unit, with only a changed Health

function getClone(sp, damage)
	local copy = WL.CustomSpecialUnitBuilder.CreateCopy(sp);
	copy.Health = copy.Health - damage;
	return copy.Build();
end

--	Returns a boolean based on if the passed unit uses the field [Health] instead of [DamageAbsorbedWhenAttacked]
--
--	Input:
--		sp			[CustomSpecialUnit]				The unit you want to know if it uses the [Health] field
--
--	Output:
--					[Boolean]					True if the unit does use the [Health] field, false if not

function unitHasHealth(sp)
	if sp.proxyType == "CustomSpecialUnit" then
		return sp.Health ~= nil;
	end
	return false;
end



--	Returns the [Health] (or [DamageToKill]) of the passed unit
--
--	Input:
--		sp			[SpecialUnit]				The unit you want to know the stats from
--
--	Output:
--					[Integer]					The 'health' of the passed unit

function getHealth(sp)
	if sp.proxyType == "CustomSpecialUnit" then
		if sp.Health ~= nil then
			return sp.Health;
		else
			return sp.DamageToKill;
		end
	else
		if sp.proxyType == "Commander" then
			return 7;
		elseif sp.proxyType == "Boss1" or sp.proxyType == "Boss4" then
			return sp.Health;
		elseif sp.proxyType == "Boss2" or sp.proxyType == "Boss3" then
			return sp.Power;
		else 
			return 0; 
		end
	end
end
