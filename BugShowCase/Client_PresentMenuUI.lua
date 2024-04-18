function Client_PresentMenuUI(rootParent, setMaxSize, setScrollable, game, close)
    local list = {9, 5, 6, 2, 7};
    print(table.concat(list, ", "));

    local output = table.sort(list);
    print(tostring(output), output == nil);
    print(table.concat(list, ", "));
end