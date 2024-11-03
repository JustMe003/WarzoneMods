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
	if windowExists(win) then
		resetWindow(win);
	end
	window(win);
	vert = newVerticalGroup("vert", "root");
	local line = newHorizontalGroup(win .. "line_info1", vert);
	newLabel(win .. "Info1", line, "Players that are below this income threshold at the end of the turn are eliminated.");
	local line = newHorizontalGroup(win .. "line_info2", vert);
	newLabel(win .. "Info2", line, "If every player is below the income threshold, then the player(s) with the most income are left alive.");
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
		local choice_table =
		{
			["a.x + c"] = getValue(iA) * i,
			["a.x² + b.x + c"] = getValue(iA) * i^2 + getValue(iB) * i,
			["a.x² + d.x.√x + b.x + e.√x + c"] = getValue(iA) * i^2 + getValue(iD) * i^1.5 + getValue(iB) * i + getValue(iE) * i^0.5,
			["a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c"] = getValue(iA) * i^2 + getValue(iD) * i^1.5 + getValue(iB) * i + getValue(iE) * i^0.5 + getValue(iF) *  math.log(i),
		}
		newLabel(win .. i, vert, "after " .. i .. " turns:   " .. math.ceil(choice_table[formula] + getValue(iC)));
	end
end

function getPower(b, p)
	if p == 0 then return 1; end
	return b * getPower(b, p - 1);
end

function saveInputs()
	inputA = getValue(iA);
	inputC = getValue(iC);
	if formula ~= "a.x + c" then
		inputB = getValue(iB);
	end
	if formula == "a.x² + d.x.√x + b.x + e.√x + c" then
		inputD = getValue(iD);
		inputE = getValue(iE);
	end
	if formula == "a.x² + d.x.√x + b.x + e.√x+ f.ln(x) + c" then
		inputD = getValue(iD);
		inputE = getValue(iE);
		inputF = getValue(iF);
	end
end