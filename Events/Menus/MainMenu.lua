require("UI");

require("Util.Util");

require("Menus.TriggerMenus.AllTriggerMenus");
require("Menus.EventMenus.AllEventMenus");
require("Menus.AssignMenu");
require("Menus.InspectMenu");
require("Menus.FAQMenu");
require("Menus.HomeButtons");

MainMenu = {};

function MainMenu.ShowMain()
    History.AddToHistory(MainMenu.ShowMain);
    UI2.DestroyWindow();
    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1));

    UI2.CreateLabel(UI2.CreateHorz(root).SetFlexibleWidth(1).SetCenter(true)).SetText("Events").SetColor(colors.Yellow);
    local line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    UI2.CreateLabel(line).SetText("Created by: ").SetColor(colors.TextColor);
    UI2.CreateLabel(line).SetText("Just_A_Dutchman_").SetColor(colors.Lime);
    
    UI2.CreateEmpty(root).SetPreferredHeight(10);
    line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    UI2.CreateButton(line).SetText("Triggers").SetColor(colors.Green).SetOnClick(TriggerMenu.ShowTriggerMenu);
    UI2.CreateEmpty(line).SetMinWidth(30);
    UI2.CreateButton(line).SetText("Events").SetColor(colors.LightBlue).SetOnClick(EventMenu.ShowExistingEvents);
    
    line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    UI2.CreateButton(line).SetText("Assign").SetColor(colors.Yellow).SetOnClick(AssignMenu.SelectTrigger);
    UI2.CreateEmpty(line).SetMinWidth(30);
    UI2.CreateButton(line).SetText("Inspect").SetColor(colors.OrangeRed).SetOnClick(InspectMenu.ShowMenu);

    line = UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1);
    UI2.CreateButton(line).SetText("FAQ").SetColor(colors.TyrianPurple).SetOnClick(FAQMenu.ShowMenu);

end
