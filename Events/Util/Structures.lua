require("Util.Util");

function replaceStructWord(str, new)
    return replaceSubString(str, "{STRUCT}", new);
end

function getStructureName(enum)
    for name, enum2 in pairs(WL.StructureType) do
        if enum == enum2 then return getReadableString(name); end
    end
    return "None";
end