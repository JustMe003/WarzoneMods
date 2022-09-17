function getJSON(t)
  local result = {};
  for key, value in pairs(tableWithData) do 
    if type(value) ~= type({}) then
      table.insert(result, string.format("%s:%s", key, value)) 
    else
      table.insert(result, string.format("%s:%s", key, getJSON(value)));
    end 
  end
  return "{" .. table.concat(result, ",") .. "}";
end

function getObjectFromJSON(s)
  local t = {};
  while #s > 1 do
    local end = string.find(s, ":");
    local key = string.sub(s, 1, end - 1);
    s = string.sub(s, end + 1, -1);
    if tonumber(key) ~= nil then
      key = tonumber(key);
    end
    local c = string.sub(s, 1, 1);
    if c == "{" then
      t[key], s = getObjectFromJSON(string.sub(s, 2, -1));
    else
      local start, end = string.find(s, "%x");
      t[key] = string.sub(s, start, end);
      if tonumber(t[key]) ~= nil then
        t[key] = tonumber(t[key]);
      end
      c = string.sub(s, end + 1, end + 1);
      s = string.sub(s, end + 2, -1);
      if c == "}" then
        return t, s;
      end
    end
  end
  return t;
end
