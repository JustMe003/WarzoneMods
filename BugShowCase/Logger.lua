local logger;

---Creates a new logger
---@param adr table | nil
function CreateNewLog(adr)
    logger = adr or {};
end

---Logs the given input
---@param str any
function Log(str)
    if logger == nil then error("No logger was created"); end
    table.insert(logger, tostring(str));
end