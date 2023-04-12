require("UI");
require("util");
function Client_PresentConfigureUI(rootParent)
	init(rootParent);
	
	formula = Mod.Settings.Formula;
	if formula == nil then formula = "ax + c"; end
	inputA = Mod.Settings.A;
	if inputA == nil then inputA = 1; end
	inputB = Mod.Settings.B;
	if inputB == nil then inputB = 0; end
	inputC = Mod.Settings.C;
	if inputC == nil then inputC = 0; end
	
	showOptions();
end

function showOptions()
	win = "showOptions";
	destroyWindow(getCurrentWindow());
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	vert = newVerticalGroup("vert", "root");
	local line = newHorizontalGroup(win .. "line1", vert);
	newLabel(win .. "FormulaSelecting", line, "Select your formula:", "Royal Blue");
	newButton(win .. "Formula", line, formula, cycleFormula, "Lime");
	newLabel(win .. "newLine", vert, "\n");
	local line = newHorizontalGroup(win .. "line2", vert);
	newLabel(win .. "A", line, "a: ", "Orange");
	iA = newNumberField(win .. "InputA", line, 0, 5, inputA, true, false);
	if formula == "ax² + bx + c" then
		local line = newHorizontalGroup(win .. "line3", vert);
		newLabel(win .. "B", line, "b: ", "Orange");
		iB = newNumberField(win .. "InputB", line, 0, 5, inputB, true, false);
	end
	local line = newHorizontalGroup(win .. "line4", vert);
	newLabel(win .. "C", line, "c: ", "Orange");
	iC = newNumberField(win .. "InputC", line, 0, 20, inputC);
	
	showCurve();
	
	newButton(win .. "RefreshCurve", vert, "Refresh", function() saveInputs(); showOptions(); end, "Green");
end

function cycleFormula()
	saveInputs();
	if formula == "ax + c" then
		formula = "ax² + bx + c";
	else
		formula = "ax + c";
	end
	showOptions();
end

function showCurve()
	for k = 0, 7 do
		local i = getPower(2, k);
		if formula == "ax + c" then		
			newLabel(win .. i, vert, "after " .. i .. " turns:   " .. round(getValue(iA) * i + getValue(iC)));
		else
			newLabel(win .. i, vert, "after " .. i .. " turns:   " .. round(i * i * getValue(iA) + getValue(iC) + getValue(iB) * i));
		end
	end
end

function getPower(b, p)
	if p == 0 then return 1; end
	return b * getPower(b, p - 1);
end

function saveInputs()
	inputA = getValue(iA);
	inputC = getValue(iC);
	if formula ~= "ax + c" then
		inputB = getValue(iB);
	end
end