FAQEnum = {
    GENERAL = 1;
    EVENTS = 2;
    TRIGGERS = 3;
    ASSIGNMENT = 4;
}

local FAQEnumMetaData = {
    [FAQEnum.GENERAL] = {
        Name = "General",
        Color = "#008000"
    },
    [FAQEnum.EVENTS] = {
        Name = "Events",
        Color = "#23A0FF"
    },
    [FAQEnum.TRIGGERS] = {
        Name = "Triggers",
        Color = "#00FF05"
    },
    [FAQEnum.ASSIGNMENT] = {
        Name = "Assignment",
        Color = "#FFFF00"
    }
}

function FAQEnum.GetFAQName(enum) 
    return FAQEnumMetaData[enum].Name;
end

function FAQEnum.GetFAQColor(enum)
    return FAQEnumMetaData[enum].Color;
end