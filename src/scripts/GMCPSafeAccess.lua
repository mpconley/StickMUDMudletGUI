-- GMCPSafeAccess.lua
-- Utility module for safe access to GMCP data to prevent runtime errors
-- when GMCP data has not yet been received

GMCPSafe = GMCPSafe or {}

-- Helper function to safely access nested GMCP tables
-- Usage: GMCPSafe.get("Char.Vitals.hp", 0)
function GMCPSafe.get(path, defaultValue)
    if not gmcp then
        return defaultValue
    end
    
    local current = gmcp
    local keys = string.split(path, ".")
    
    for _, key in ipairs(keys) do
        if type(current) ~= "table" or current[key] == nil then
            return defaultValue
        end
        current = current[key]
    end
    
    return current
end

-- Helper function to check if a GMCP path exists
function GMCPSafe.exists(path)
    if not gmcp then
        return false
    end
    
    local current = gmcp
    local keys = string.split(path, ".")
    
    for _, key in ipairs(keys) do
        if type(current) ~= "table" or current[key] == nil then
            return false
        end
        current = current[key]
    end
    
    return true
end

-- Helper function to safely get numeric values
function GMCPSafe.getNumber(path, defaultValue)
    local value = GMCPSafe.get(path, defaultValue)
    local num = tonumber(value)
    return num or defaultValue
end

-- Helper function to safely get string values
function GMCPSafe.getString(path, defaultValue)
    local value = GMCPSafe.get(path, defaultValue)
    if type(value) == "string" then
        return value
    end
    return defaultValue or ""
end

-- Helper function to safely get table values
function GMCPSafe.getTable(path, defaultValue)
    local value = GMCPSafe.get(path, defaultValue)
    if type(value) == "table" then
        return value
    end
    return defaultValue or {}
end

-- Safe wrapper for functions that depend on GMCP data
function GMCPSafe.execute(requiredPaths, func, ...)
    -- Check if all required GMCP paths exist
    for _, path in ipairs(requiredPaths) do
        if not GMCPSafe.exists(path) then
            -- GMCP data not available yet, skip execution
            return false
        end
    end
    
    -- All required data is available, execute the function
    local success, result = pcall(func, ...)
    if not success then
        print("Error in GMCP function: " .. tostring(result))
        return false
    end
    
    return true, result
end

-- Initialize default GMCP structure to prevent nil access errors
function GMCPSafe.initializeDefaults()
    gmcp = gmcp or {}
    
    -- Initialize common GMCP structures with empty defaults
    if not gmcp.Char then
        gmcp.Char = {
            Vitals = { hp = 0, maxhp = 1, sp = 0, maxsp = 1, fp = 0, maxfp = 1 },
            Status = { 
                gold = 0, bank = 0, enemy = "None", enemy_health = "None",
                brave = "No", pkable = "No", poisoned = "No", confused = "No",
                hallucinating = "No", drunk = "No", hunger = "No", thirst = "No",
                invis = "No", frog = "No", summonable = "No", rest = "No"
            },
            Items = {
                List = { location = "", items = {} },
                Add = { location = "", item = {} },
                Remove = { location = "", item = {} },
                Update = { location = "", item = {} }
            },
            Help = { List = {} },
            Session = { Training = {} },
            Abilities = { Remove = {}, Update = {} }
        }
    end
    
    if not gmcp.Room then
        gmcp.Room = {
            Info = { name = "Unknown Room", area = "Unknown Area", exits = {} },
            AddPlayer = {},
            RemovePlayer = {}
        }
    end
    
    if not gmcp.Comm then
        gmcp.Comm = {
            Channel = {
                Text = { channel = "", text = "" }
            }
        }
    end
    
    if not gmcp.Group then
        gmcp.Group = {
            members = {},
            leader = "",
            groupname = ""
        }
    end
    
    if not gmcp.Game then
        gmcp.Game = {
            Players = { List = {} }
        }
    end
end

-- Call initialization on module load
GMCPSafe.initializeDefaults()
