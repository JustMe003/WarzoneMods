require("UI")
function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, ClientGame, close, bonusID)
	Init(rootParent);
	root = GetRoot();
	colors = GetColors();
	if bonusID == nil then
		showMenu();
	else
		showBonusDetails(bonusID);
	end
end

function showMenu()

end

function showBonusDetails(bonusID)
	DestroyWindow();
	SetWindow("showBonus");

	
end