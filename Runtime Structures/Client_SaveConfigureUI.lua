---Client_SaveConfigureUI hook
---@param alert fun(message: string) # Alert the player that something is wrong, for example, when a setting is not configured correctly. When invoked, cancels the player from saving and returning
---@param addCard fun(name: string, description: string, filename: string, piecesForWholeCard: integer, piecesPerTurn: integer, initialPieces: integer, cardWeight: number, duration: integer | nil, expireBehaviour: ActiveCardExpireBehaviorOptions): CardID # Creates a custom card. Can be invoked multiple times to create multiple cards. Every invokation will return the CardID of the just created card, make sure to save this in the settings of your mod
function Client_SaveConfigureUI(alert, addCard)
	saveInputs(inputs);
	if #config < 1 then
		alert("You must create 1 group in order to use this mod. Otherwise, please remove the mod from your game");
	end
	for i, group in ipairs(config) do
		if group.Amount < 1 then
			alert("The amount of structures must be higher than 0: group " .. i);
		end
		if group.Interval < 1 then
			alert("The interval of turns must be higher than 0: group " .. i);
		end
		if #group.Structures < 1 then
			alert("The number of structure types must be higher than 0: group " .. i);
		end
	end
	Mod.Settings.Config = config;
end
