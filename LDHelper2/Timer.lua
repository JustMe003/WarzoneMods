----------------------------------------
--- Just_A_Dutchman_'s Timer library ---
----------------------------------------


---Objects

---@class TimeStamp
---@field Name string # The name of the timer
---@field Time number # The number of miliseconds

---@class TimerData
---@field Name string # The name of the timer(s)
---@field TotalSeconds number # The total number of seconds this timer has recorded
---@field TimesUsed integer # The number of times this timer was used
---@field ShortestTime number? # The shortest recorded time in seconds. To make the Timers keep track of this field, set the `TrackShortestTime` to true in Config
---@field LongestTime number? # The longest recorded time in seconds. To make the Timers keep track of this field, set the `TrackLongestTime` to true in Config
---@field Times number[]? # All the recorded times in seconds. To make the Timers keep track of this field, set the `TrackAllTimes` to true in Config

---@class TimerConfig
---@field PrintTimesWhenStopped boolean? # When true, each timer that stops will immediately print its results. Default = true
---@field PrintTimerUpdateWhenStopped boolean? # When true, each timer that stops will print the updated values of all the timer runs so far. Default = false
---@field TrackShortestTime boolean? # When true, timers will keep track of the shortest time recorded with the same name. Default = false
---@field TrackLongestTime boolean? # When true, timers will keep track of the longest time recorded with the same name. Default = false
---@field TrackAllTimes boolean? # When true, timers will keep track of all the recorded times with the same name. Default = true







-----------------------------------
--- Do not modify below here!!! ---
-----------------------------------


local SCOPE = {};
local print = print;
local table = table;
local error = error;
local math = math;
local type = type;

Timer = SCOPE;

_ENV = {};




local TIMER_PRINT = function(s) print("[TIMER] " .. s) end;

local Timers;
local StartTimeStamps;
local WL;
local Initialized = false;

-- Configurations
local PrintTimesWhenStopped = true;
local PrintTimerUpdateWhenStopped = false;
local TrackShortestTime = false;
local TrackLongestTime = false;
local TrackAllTimes = false;


---Converts the time from miliseconds to seconds
---@return number # Time in seconds
function getTimeInSeconds()
    return WL.TickCount() / 1000;
end

---Creates and returns a [TimeStamp](lua://TimeStamp)
---@param name string # The name of the timer
---@param timeStamp number # The value of timer
---@return TimeStamp # The created [TimeStamp](lua://TimeStamp)
function CreateTimeStamp(name, timeStamp)
    return {
        Name = name;
        Time = timeStamp or getTimeInSeconds();
    }
end

---Calculate and creates a [TimeStamp](lua://TimeStamp) of the final result
---@param stamp TimeStamp # The start of the timer
---@return TimeStamp
function FinishTimeStamp(stamp)
    return CreateTimeStamp(stamp.Name, getTimeInSeconds() - stamp.Time);
end

---Function that throws an error
---@param msg string # The error message
---@param level integer # unkown
function ThrowError(msg, level)
    error("[TIMER] ERROR! " .. msg, level);
end

---Rounds the given number down
---@param n number # The number to be rounded down
---@param nDec integer # The number of decimals after the dot
---@return number # The rounded number
function Round(n, nDec)
    local dec = 10 ^ nDec;
    return math.floor(n * dec + 0.5) / dec;
end

---Helper function that returns `a` if the guard is true, otherwise returns `b`
---@param guard boolean # An expression that resolves to a boolean
---@param a any # a
---@param b any # b
---@return any # `a` if the guard is true, otherwise `b`
function AorB(guard, a, b)
    if guard then return a; else return b; end
end

---Updates the Timer
---@param name string # Name of the timer
---@param finishedStamp TimeStamp # The final time stamp
function UpdateTimer(name, finishedStamp)
    local timer = Timers[name];
    if timer == nil then
        timer = {
            Name = name;
            TotalSeconds = finishedStamp.Time;
            TimesUsed = 1;
            ShortestTime = AorB(TrackShortestTime, finishedStamp.Time, nil);
            LongestTime = AorB(TrackLongestTime, finishedStamp.Time, nil);
            Times = AorB(TrackAllTimes, {finishedStamp.Time}, nil);
        };
        Timers[name] = timer;
    else
        timer.TotalSeconds = timer.TotalSeconds + finishedStamp.Time;
        timer.TimesUsed = timer.TimesUsed + 1;
        if TrackShortestTime and timer.ShortestTime ~= nil then
            timer.ShortestTime = math.min(timer.ShortestTime, finishedStamp.Time);
        end 
        if TrackLongestTime and timer.LongestTime ~= nil then
            timer.LongestTime = math.max(timer.LongestTime, finishedStamp.Time);
        end 
        if TrackAllTimes and timer.Times ~= nil then
            table.insert(timer.Times, finishedStamp.Time);
        end
    end
end

---Prints all the data of a [TimerData](lua://TimerData) object
---@param timer TimerData # The [TimerData](lua://TimerData) object
function PrintTimerUpdate(timer)
    TIMER_PRINT(timer.Name .. " updated!");
    print("\tTotal time: " .. Round(timer.TotalSeconds, 4) .. " seconds");
    print("\tRecord count: " .. timer.TimesUsed);
    print("\tAverage time taken: " .. Round(timer.TotalSeconds / timer.TimesUsed, 4) .. " seconds");
    if TrackShortestTime and timer.ShortestTime ~= nil then
        print("\tShortest recorded time: " .. Round(timer.ShortestTime, 4) .. " seconds");
    end
    if TrackLongestTime and timer.LongestTime ~= nil then
        print("\tLongest recorded time: " .. Round(timer.LongestTime, 4) .. " seconds");
    end
end

---Initializes the necessary timer components
---@param wl WL # The [WL](https://www.warzone.com/wiki/Mod_API_Reference:WL) constants table
---See [documentation](https://github.com/JustMe003/ModTemplates/blob/main/README.md#timer-initialization)
function SCOPE.Init(wl) 
    WL = wl;
    Timers = {};
    StartTimeStamps = {};
    Initialized = true;
end

---Function to configure the timers 
---@param params TimerConfig # The changed configuration values: see [TimerConfig](lua://TimerConfig)
---```
---Timer.Config({
--- PrintTimesWhenStopped: boolean;
--- PrintTimerUpdateWhenStopped: boolean;
--- TrackShortestTime: boolean;
--- TrackLongestTime: boolean;
--- TrackAllTimes: boolean;
---})
---```
---See [documentation](https://github.com/JustMe003/ModTemplates/blob/main/README.md#timer-config)
function SCOPE.Config(params)
    PrintTimesWhenStopped = AorB(params.PrintTimesWhenStopped ~= nil and type(params.PrintTimesWhenStopped) == "boolean", params.PrintTimesWhenStopped, true);
    PrintTimerUpdateWhenStopped = AorB(params.PrintTimerUpdateWhenStopped ~= nil and type(params.PrintTimerUpdateWhenStopped) == "boolean", params.PrintTimerUpdateWhenStopped, false);
    TrackShortestTime = AorB(params.TrackShortestTime ~= nil and type(params.TrackShortestTime) == "boolean", params.TrackShortestTime, false);
    TrackLongestTime = AorB(params.TrackLongestTime ~= nil and type(params.TrackLongestTime) == "boolean", params.TrackLongestTime, false);
    TrackAllTimes = AorB(params.TrackAllTimes ~= nil and type(params.TrackAllTimes) == "boolean", params.TrackAllTimes, false);
end

---Starts a new Timer
---@param name string # The name of the timer
---```
---local name = "Some name";
---Timer.Start(name);
---...
---Timer.Stop(name);
---```
---See [documentation](https://github.com/JustMe003/ModTemplates/blob/main/README.md#timer-start)
function SCOPE.Start(name)
    if not Initialized then ThrowError("Timer was not Initialized! Please use the `InitTimer(WL)` function first before calling `Start`"); end
    if name == nil then ThrowError("Name was not set. Make sure you enter a valid name for the timer!"); return; end
    if StartTimeStamps[name] ~= nil then ThrowError("'" .. name .. "' has already started! You cannot have the same timer running twice"); end;
    StartTimeStamps[name] = CreateTimeStamp(name);
end

---Stops a timer
---@param name string # Name of the timer to stop
---```
----- Make sure that there exists a timer with "Some name"
---local name = "Some name";
---Timer.Start(name);
---...
---Timer.Stop(name);
---```
---See [documentation](https://github.com/JustMe003/ModTemplates/blob/main/README.md#timer-stop)
function SCOPE.Stop(name)
    if not Initialized then ThrowError("Timer was not Initialized! Please use the `InitTimer(WL)` function first before calling `Stop`"); end
    if name == nil then ThrowError("Name was not set. Make sure you enter a valid name for the timer!"); return; end
    
    local stamp = StartTimeStamps[name];
    if stamp == nil then ThrowError("Could not find timer with name '" .. name .. "'!"); end
    
    local finishedStamp = FinishTimeStamp(stamp);
    
    if PrintTimesWhenStopped then
        TIMER_PRINT(name .. " stopped! Time recorded was: " .. Round(finishedStamp.Time, 4) .. " seconds");
    end
    
    UpdateTimer(name, finishedStamp);
    
    if PrintTimerUpdateWhenStopped then
        PrintTimerUpdate(Timers[name]);
    end
    
    StartTimeStamps[name] = nil;
end

---Returns the [TimerData](lua://TimerData)
---@return table<string, TimerData> # The [TimerData](lua://TimerData)
---```
---local timers = Timer.GetAllTimers();
---```
---See [documentation](https://github.com/JustMe003/ModTemplates/blob/main/README.md#timer-get-all-timers)
function SCOPE.GetAllTimers() 
    if not Initialized then ThrowError("Timer was not Initialized! Please use the `InitTimer(WL)` function first before calling `Stop`"); end
    return Timers; 
end

---Returns the [TimerData](lua://TimerData) of the timer with the passed name
---@param name string # The name of the timer
---@return TimerData # The [TimerData](lua://TimerData) of the timer
---```
---local name = "Some name";
----- Start and stop the timer
---local timer = Timer.GetTimer(name);
---```
---See [documentation](https://github.com/JustMe003/ModTemplates/blob/main/README.md#timer-get-timer)
function SCOPE.GetTimer(name) 
    if not Initialized then ThrowError("Timer was not Initialized! Please use the `InitTimer(WL)` function first before calling `Stop`"); end
    if name == nil then ThrowError("Name was not set. Make sure you enter a valid name for the timer!"); end
    if Timers[name] == nil then ThrowError("Could not find timer with name '" .. name .. "'!"); end
    return Timers[name];
end
