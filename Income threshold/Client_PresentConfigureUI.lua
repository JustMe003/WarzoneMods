require("UI");
require("util");
function Client_PresentConfigureUI(rootParent)
	init(rootParent);
	
	local allowed_formulas = {
		"a.x + c",
		"a.x² + b.x + c",
		"a.x² + d.x.√x + b.x + e.√x + c",
		"a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c"
	}
	formula = Mod.Settings.Formula;
	if not isIn(formula, allowed_formulas) then formula = "a.x + c"; end
	inputA = Mod.Settings.A;
	if inputA == nil then inputA = 1; end
	inputB = Mod.Settings.B;
	if inputB == nil then inputB = 0; end
	inputC = Mod.Settings.C;
	if inputC == nil then inputC = 0; end
	inputD = Mod.Settings.D;
	if inputD == nil then inputD = 0; end
	inputE = Mod.Settings.E;
	if inputE == nil then inputE = 0; end
	inputF = Mod.Settings.F;
	if inputF == nil then inputF = 0; end
	
	showOptions();
end

function showOptions()
	win = "showOptions";
	destroyWindow(getCurrentWindow());
	window(win);
	vert = newVerticalGroup("vert", "root");
	local line = newHorizontalGroup(win .. "line1", vert);
	newLabel(win .. "FormulaSelecting", line, "Select your formula:", "Royal Blue");
	newButton(win .. "Formula", line, formula, cycleFormula, "Lime");
	newLabel(win .. "newLine", vert, "\n");
	local line = newHorizontalGroup(win .. "line2", vert);
	newLabel(win .. "A", line, "a: ", "Orange");
	iA = newNumberField(win .. "InputA", line, 0, 10, inputA, true, false);
	if formula ~= "a.x + c" then
		local line = newHorizontalGroup(win .. "line3", vert);
		newLabel(win .. "B", line, "b: ", "Orange");
		iB = newNumberField(win .. "InputB", line, -100, 100, inputB, true, false);
	end
	local line = newHorizontalGroup(win .. "line4", vert);
	newLabel(win .. "C", line, "c: ", "Orange");
	iC = newNumberField(win .. "InputC", line, -100, 100, inputC);
	if formula == "a.x² + d.x.√x + b.x + e.√x + c" then
		local line = newHorizontalGroup(win .. "line5", vert);
		newLabel(win .. "D", line, "d: ", "Orange");
		iD = newNumberField(win .. "InputD", line, -100, 100, inputD, true, false);
		local line = newHorizontalGroup(win .. "line6", vert);
		newLabel(win .. "E", line, "e: ", "Orange");
		iE = newNumberField(win .. "InputE", line, -100, 100, inputE, true, false);
	end
	if formula == "a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c" then
		local line = newHorizontalGroup(win .. "line5", vert);
		newLabel(win .. "D", line, "d: ", "Orange");
		iD = newNumberField(win .. "InputD", line, -100, 100, inputD, true, false);
		local line = newHorizontalGroup(win .. "line6", vert);
		newLabel(win .. "E", line, "e: ", "Orange");
		iE = newNumberField(win .. "InputE", line, -100, 100, inputE, true, false);
		local line = newHorizontalGroup(win .. "line7", vert);
		newLabel(win .. "F", line, "f: ", "Orange");
		iF = newNumberField(win .. "InputF", line, -100, 100, inputF, true, false);
	end
	
	showCurve();
	
	newButton(win .. "RefreshCurve", vert, "Refresh", function() saveInputs(); showOptions(); end, "Green");
end

function cycleFormula()
	saveInputs();
	local choice_table =
	{
		["a.x + c"] = "a.x² + b.x + c",
		["a.x² + b.x + c"] = "a.x² + d.x.√x + b.x + e.√x + c",
		["a.x² + d.x.√x + b.x + e.√x + c"] = "a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c",
		["a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c"] = "a.x + c",
	}
	formula = choice_table[formula];
	
	showOptions();
end

function showCurve()
	for k = 0, 8 do
		local i = getPower(2, k);
		value = getValue(iC);
		if formula == "a.x + c" then
			value = value + getValue(iA) * i;
		elseif formula == "a.x² + b.x + c" then
			value = value + getValue(iA) * i^2 + getValue(iB) * i;
		elseif formula == "a.x² + d.x.√x + b.x + e.√x + c" then
			value = value + getValue(iA) * i^2 + getValue(iD) * i^1.5 + getValue(iB) * i + getValue(iE) * i^0.5;
		else
			value = value + getValue(iA) * i^2 + getValue(iD) * i^1.5 + getValue(iB) * i + getValue(iE) * i^0.5 + getValue(iF) *  math.log(i);
		end
		newLabel(win .. i, vert, "after " .. i .. " turns:   " .. math.ceil(value));
	end
end

function saveInputs()
	print("A");
	inputA = getValue(iA);
	print("C");
	inputC = getValue(iC);
	if formula ~= "a.x + c" then
		print("B");
		inputB = getValue(iB);
	end
	if formula == "a.x² + d.x.√x + b.x + e.√x + c" then
		print("D");
		inputD = getValue(iD);
		print("E");
		inputE = getValue(iE);
	end
	if formula == "a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c" then
		print("D");
		inputD = getValue(iD);
		print("E");
		inputE = getValue(iE);
		print("F");
		inputF = getValue(iF);
	end
	print("finished");
end
