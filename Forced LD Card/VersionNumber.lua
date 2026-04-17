---@class VersionNumber
---@field CreateVersionNumberString fun(major: integer, minor: integer?, patch: integer?): VersionString
---@field VersionIsEqualOrHigher fun(base: VersionString, version: VersionString): boolean

---@class VersionNumber
---@field Major integer # Major version number
---@field Minor integer # Minor version number
---@field Patch integer # Patch version number

---@alias VersionString string

VersionNumber = {};

---Splits the input string by searching for the given pattern
---@param str string
---@param pat string
---@return string[] # All the splits of the string, without the pattern
local split = function(str, pat)
    local t = {}  -- NOTE: use {n = 0} in Lua-5.0
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = str:find(fpat, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(t,cap)
        end
        last_end = e+1
        s, e, cap = str:find(fpat, last_end)
    end
    if last_end <= #str then
        cap = str:sub(last_end)
        table.insert(t, cap)
    end
    return t
end

---Returns a version table gathered from the input string
---@param s VersionString
---@return VersionNumber
local getVersionNumber = function(s)
    local splits = split(s, "%.");
    return {
        Major = tonumber(splits[1]);
        Minor = tonumber(splits[2]) or 0;
        Patch = tonumber(splits[3]) or 0;
    }
end

---Returns a version number string
---@param major integer
---@param minor integer?
---@param patch integer?
---@return VersionString # \"{major}.{minor or 0}.{patch or 0}\"
function VersionNumber.CreateVersionNumberString(major, minor, patch)
    return major .. "." .. minor or 0 .. "." .. patch or 0;
end

    

---Returns whether the version number is equal or higher than the required version
---@param base VersionString
---@param version VersionString
---@return boolean
function VersionNumber.VersionIsEqualOrHigher(base, version)
    local b = getVersionNumber(base);
    local v = getVersionNumber(version);
    
    return not b or v.Major > b.Major or v.Minor > b.Minor or v.Patch >= b.Patch;
end

