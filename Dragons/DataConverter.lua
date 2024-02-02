--                      Data Converter                      --
--                 Made by:  Just_A_Dutchman_               --
--                                                          --
--                      DO NOT MODIFY!                      --
--
--      Data converter from tables to strings and vice versa.
--      Made for compatibility between mods when storing data in custom special units
--
-- HOW TO USE
--      Create a table. This table can contain anything, just note that functions
--      cannot be converted. When you want to store your table into a string, call
--      dataToString() with as argument the table you want to convert into a string.
--
--      When you want to modify / read the data you stored, call stringToData() with
--      as argument the string you want to convert into a table. ONLY PROVIDE STRINGS
--      THAT WERE CREATED BY THE dataToString() FUNCTION!
--
--  WHEN TO USE
--      When you want to store data in a place where only strings can be saved. You 
--      might have a table containing multiple fields with data and you want to store
--      all of it, these functions allow you to do this
--
--  CODE SNIPPETS / EXAMPLES
--[[    -- You can copy everything below this until line 70
        local t = {};                           -- Create a table
        t.array = {};                           -- Create field [array] in the table
        table.insert(t.array, 1);               -- Populate the field [array] with values
        table.insert(t.array, 3);
        table.insert(t.array, 2);
        t.string = "Hello, World!";             -- Create field [string] and assign a string value
        t.pi = 3.14;                            -- Create field [pi] and assign a number value
        t.bool1 = true;                         -- Create field [bool1] and assign boolean value
        t.bool2 = false;                        -- Create field [bool2] and assign boolean value

        -- Now we have a table filled with data, and we want to convert it into a string
        local string = dataToString(t); 
        print(string);                          -- Will print the string: "{array={1=1;2=3;3=2};string="Hello, World!"□;pi=3.14;bool1=true;bool2=false}"

        -- DO NOT MODIFY THE STRING AT ANY TIME!
        -- Doing so can break the format and will corrupt the data

        -- Now we can store the string in the place we want it to

        -- Say we now want to read and / or modify the data
        -- We must convert it back into a table first
        
        local converted = stringToData(string);

        -- Watch the result of all the prints below
        print(t.string, converted.string, t.string == converted.string);
        print(t.pi, converted.pi, t.pi == converted.pi);
        print(t.bool1, converted.bool1, t.bool1 == converted.bool1);
        print(t.bool2, converted.bool2, t.bool2 == converted.bool2);
        print(t.array[1], converted.array[1], t.array[1] == converted.array[1]);
        print(t.array[2], converted.array[2], t.array[2] == converted.array[2]);
        print(t.array[3], converted.array[3], t.array[3] == converted.array[3]);

        -- As we can see, all the data is the same
        -- Now, we can make changes if we want
        converted.newField = "something";       -- Add new field [newField]      
        converted.array = nil;                  -- Remove the array

        -- Now we want to save our changes we made
        -- We simply convert the modified table into a string again and store it
        local newString = dataToString(converted);
        print(newString);


        -- And store this string in the same place we got the original string
        -- That's it!
]]




--  dataToString(t)
--  Converts the given table into a string
--      t       [table]       The table containing the data you want to convert into a string


function dataToString(t)
    if t == nil then return "\29{}\29"; end
    local f;
    f = function(t)
            if t == nil then return "\29{}\29"; end
            local result = {};
            for key, value in pairs(t) do
                if key ~= "DO_NOT_MODIFY_NOR_READ" then
                    if type(value) == type({}) then
                        table.insert(result, string.format("%s=%s", key, f(value)));
                    elseif type(value) == type("") then
                        table.insert(result, string.format("%s=\"%s\"\29", key, value));
                    else
                        table.insert(result, string.format("%s=%s", key, tostring(value)));
                    end
                end
            end
            return "{" .. table.concat(result, ";") .. "}";
        end

    local s = "";
    if t.DO_NOT_MODIFY_NOR_READ ~= nil and t.DO_NOT_MODIFY_NOR_READ.Prefix_DataConverter_JAD ~= nil then
        s = s .. t.DO_NOT_MODIFY_NOR_READ.Prefix_DataConverter_JAD;
    end
    s = s .. "\29" .. f(t) .. "\29";
    if t.DO_NOT_MODIFY_NOR_READ ~= nil and t.DO_NOT_MODIFY_NOR_READ.Suffix_DataConverter_JAD ~= nil then
        s = s .. t.DO_NOT_MODIFY_NOR_READ.Suffix_DataConverter_JAD;
    end
    t.DO_NOT_MODIFY_NOR_READ = nil;
    return s;
end


--  stringToData
--  Converts the given string into a table
--  ONLY PASS STRINGS THAT ARE FORMATTED BY THE dataToString() FUNCTION
--      s       [string]        The string you want to convert into a table

function stringToData(s)
    local f;
    f = function(s)
            if s == nil then return {}; end
            local firstPar = s:find("{");
            s = s:sub(firstPar + 1, -1);
            local t = {};
            while #s > 1 do
                if s:sub(1, 1) == "}" then return t, s:sub(2, -1); end
                local ending = s:find("=");
                local key = s:sub(s:find("%w+"), ending - 1);
                s = s:sub(ending + 1, -1);
                if tonumber(key) ~= nil then
                    key = tonumber(key);
                end
                local c = s:sub(1, 1);
                if key == nil then
                    return t, "";
                end
                if c == "{" then
                    t[key], s = f(s);
                    c = s:sub(1, 1);
                    if c == "}" then
                        return t, s:sub(2, -1);
                    end
                else
                    local start, last = s:find("[^}=;]*");
                    if c == "\"" then
                        local mark = string.find(s:sub(start + 1, -1), "\29");
                        local value = s:sub(start + 1, mark - 1);
                        t[key] = value;
                        last = mark + 1;
                    else    
                        local value = s:sub(start, last);
                        if value == "true" then
                            t[key] = true;
                        elseif value == "false" then
                            t[key] = false;
                        else
                            t[key] = tonumber(value);
                        end
                    end
                    c = s:sub(last + 1, last + 1);
                    s = s:sub(last + 2, -1);
                    if c == "}" then
                        return t, s;
                    end
                end
            end
            return t;
        end
    
    if s == nil then
        return {};
    end

    local start = s:find("\29{");
    if start == nil then print("Couldn't find the start of the data"); return {}; end
    local endOfData = s:find("}\29");
    if endOfData == nil then print("Couldn't find the end of the data"); return {}; end

    local t = f(s:sub(start + 1, endOfData));
    t.DO_NOT_MODIFY_NOR_READ = {};
    t.DO_NOT_MODIFY_NOR_READ.Prefix_DataConverter_JAD = s:sub(0, start - 1);
    t.DO_NOT_MODIFY_NOR_READ.Suffix_DataConverter_JAD = s:sub(endOfData + 2, -1);
    return t;
end