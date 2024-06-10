function getKeyFromMap(key)
    for numKey, stringKey in ipairs(map) do
        if stringKey == key then
            return numKey;
        end
    end
    table.insert(map, key);
    return #map;
end