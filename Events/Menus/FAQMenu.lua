require("Enums.FAQEnums");

FAQMenu = {};

local questions = {
    {
        Question = "What does this mod do?";
        Answer = "This mod allows the game creator to create custom events. Events get triggered on certain conditions (such as a minimum number of armies) and can modify the game in multiple ways.";
        Category = FAQEnum.GENERAL;
    },
    {
        Question = "Why would one use this mod?";
        Answer = "Because it will enrich the game with custom events. You can use this mod in every game, but it was created with the intention to enrich custom scenario games. The mod has numerous features that involve specific slots, one can for example create events that only get triggered by some slots";
        Category = FAQEnum.GENERAL;
    },
    {
        Question = "When will a custom event be played?";
        Answer = "When a custom event is played is determined entirely by the assigned trigger. Triggers are like a list of requirements, where all the requirements need to be met before the custom event is played.";
        Category = FAQEnum.GENERAL;
    },
    {
        Question = "What is a trigger?";
        Answer = "A trigger is like a list of requirements, and is connected to one or more events. When all requirements are met, the trigger will allow the connected custom events to be played.";
        Category = FAQEnum.TRIGGERS;
    },
    {
        Question = "Are all the requirements optional?";
        Answer = "Yes. All requirements are optional. As the game creator, you decide which requirements need to be met. The mod will not look at any other requirements";
        Category = FAQEnum.TRIGGERS;
    },
    {
        Question = "Why are there different trigger types?";
        Answer = "Triggers ";
        Category = FAQEnum.TRIGGERS;
    }
}

local closeText = "?";
local openText = "^";


local showQuestions = function(root, faq)
    for _, q in pairs(faq) do
        local line = UI2.CreateHorz(root).SetFlexibleWidth(1);
        local vert;
        local button;
        local label;
        button = UI2.CreateButton(line).SetText(closeText).SetColor(colors.RoyalBlue).SetOnClick(function()
            if button.GetText() == closeText then
                button.SetText(openText);
                label = UI2.CreateLabel(vert).SetText(q.Answer).SetColor(colors.TextDefault);
            else
                button.SetText(closeText);
                UI2.Destroy(label);
            end
        end);

        UI2.CreateLabel(line).SetText(q.Question).SetColor(colors.TextLight).SetAlignment(WL.TextAlignmentOptions.Center);
        vert = UI2.CreateVert(root);
        UI2.CreateEmpty(root).SetMinHeight(5);
    end
end

function FAQMenu.ShowMenu()
    UI2.DestroyWindow();

    local root = UI2.CreateWindow(UI2.CreateVert(GlobalRoot).SetFlexibleWidth(1)).SetCenter(true);

    UI2.CreateLabel(UI2.CreateHorz(root).SetCenter(true).SetFlexibleWidth(1)).SetText("FAQ").SetColor(colors.TextDefault);

    UI2.CreateEmpty(root).SetMinHeight(10);

    UI2.CreateLabel(root).SetText("On this page you will find questions that are frequently asked. If you have a question that is not answered here, feel free to send me (Just_A_Dutchman_) a message! You can find some links in the [About] page").SetColor(colors.TextDefault);

    showQuestions(root, questions);
end