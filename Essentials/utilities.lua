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