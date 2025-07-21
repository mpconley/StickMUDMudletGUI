-- WindowResize.lua
-- Enhanced window resizing responsiveness for the StickMUD GUI

GUI.WindowResize = GUI.WindowResize or {}

-- Store initial window dimensions for responsive calculations
GUI.WindowResize.lastWidth = nil
GUI.WindowResize.lastHeight = nil
GUI.WindowResize.resizeTimer = nil
GUI.WindowResize.lastOrientation = nil

-- Function to update borders based on current window size
function GUI.WindowResize.updateBorders()
    local w, h = getMainWindowSize()
    
    -- Update borders with responsive calculations
    setBorderLeft(0)
    setBorderTop(math.max(30, h/20))  -- Minimum 30px for header
    setBorderBottom(math.max(50, h/10))  -- Minimum 50px for footer
    setBorderRight(math.max(200, w/2.5))  -- Minimum 200px for right panel
end

-- Function to handle layout adjustments for different screen sizes
function GUI.WindowResize.adjustLayoutForSize()
    local w, h = getMainWindowSize()
    
    -- Detect screen size categories
    local isVerySmall = w < 800 or h < 600
    local isSmall = w < 1024 or h < 768
    local isTablet = w < 1366 and w >= 768
    local isLarge = w >= 1920
    
    -- Adjust font sizes based on window size
    local scaleFactor = 1.0
    if isVerySmall then
        scaleFactor = 0.7
    elseif isSmall then
        scaleFactor = 0.8
    elseif isTablet then
        scaleFactor = 0.9
    elseif isLarge then
        scaleFactor = 1.2
    end
    
    -- Update default font sizes in preferences if they exist
    if content_preferences then
        for consoleName, prefs in pairs(content_preferences) do
            if prefs.fontSize and type(prefs.fontSize) == "number" then
                -- Store original size if not already stored
                if not prefs.originalFontSize then
                    prefs.originalFontSize = prefs.fontSize
                end
                
                local newSize = math.max(6, math.floor(prefs.originalFontSize * scaleFactor))
                
                -- Apply new font size to active consoles
                local consoleShortName = consoleName:gsub("GUI%.", "")
                if GUI[consoleShortName] and GUI[consoleShortName].setFontSize then
                    GUI[consoleShortName]:setFontSize(newSize)
                    if GUI[consoleShortName].resetAutoWrap then
                        GUI[consoleShortName]:resetAutoWrap()
                    end
                end
            end
        end
    end
    
    -- Apply size-specific layout adjustments
    if isVerySmall then
        GUI.WindowResize.applyVerySmallMode()
    elseif isSmall then
        GUI.WindowResize.applyCompactMode()
    elseif isTablet then
        GUI.WindowResize.applyTabletMode()
    else
        GUI.WindowResize.applyNormalMode()
    end
end

-- Very small screen mode (mobile-like)
function GUI.WindowResize.applyVerySmallMode()
    -- Reduce all margins and padding significantly
    if GUI.BoxFooterCSS then
        GUI.BoxFooterCSS:set("margin", "1px")
        GUI.BoxFooterCSS:set("padding", "1px")
    end
    if GUI.BoxHeaderCSS then
        GUI.BoxHeaderCSS:set("margin", "1px")
        GUI.BoxHeaderCSS:set("padding", "1px")
    end
    -- Consider hiding less essential elements
end

-- Tablet mode
function GUI.WindowResize.applyTabletMode()
    -- Moderate adjustments for tablet-sized screens
    if GUI.BoxFooterCSS then
        GUI.BoxFooterCSS:set("margin", "3px")
    end
    if GUI.BoxHeaderCSS then
        GUI.BoxHeaderCSS:set("margin", "3px")
    end
end

-- Compact mode for smaller screens
function GUI.WindowResize.applyCompactMode()
    -- Reduce padding and margins in CSS
    if GUI.BoxFooterCSS then
        GUI.BoxFooterCSS:set("margin", "2px")
    end
    if GUI.BoxHeaderCSS then
        GUI.BoxHeaderCSS:set("margin", "2px")
    end
end

-- Normal mode for larger screens
function GUI.WindowResize.applyNormalMode()
    -- Restore normal padding and margins
    if GUI.BoxFooterCSS then
        GUI.BoxFooterCSS:set("margin", "5px")
    end
    if GUI.BoxHeaderCSS then
        GUI.BoxHeaderCSS:set("margin", "5px")
    end
end

-- Function to reposition and resize GUI elements
function GUI.WindowResize.updateGUIElements()
    local w, h = getMainWindowSize()
    
    -- Update main layout containers if they exist
    if GUI.Right then
        GUI.Right:resize("40%", "100%")
    end
    
    if GUI.Top then
        GUI.Top:resize("60%", "7%")
    end
    
    if GUI.Bottom then
        GUI.Bottom:resize("60%", "10%")
    end
    
    -- Update content and chat boxes
    if GUI.ContentBox then
        GUI.ContentBox:resize("50%", "37%")
    end
    
    if GUI.ChatBox then
        GUI.ChatBox:resize("50%", "38%")
    end
    
    if GUI.MenuBox then
        GUI.MenuBox:resize("50%", "85%")
    end
    
    -- Update consoles to match their parent containers
    GUI.WindowResize.updateConsolePositions()
end

-- Function to update console positions and sizes
function GUI.WindowResize.updateConsolePositions()
    -- Update content consoles
    if GUI.ContentBox then
        local contentItems = {
            "WieldedWeaponsConsole", "WornArmourConsole", "InventoryConsole", 
            "RoomConsole", "InfoScrollBox", "AbilitiesConsole", "MapperConsole"
        }
        
        for _, consoleName in ipairs(contentItems) do
            if GUI[consoleName] then
                GUI[consoleName]:move(GUI.ContentBox:get_x(), GUI.ContentBox:get_y())
                GUI[consoleName]:resize(GUI.ContentBox:get_width(), GUI.ContentBox:get_height())
            end
        end
    end
    
    -- Update chat consoles
    if GUI.ChatBox then
        local chatItems = {
            "ChatAllConsole", "ChatGuildConsole", "ChatClanConsole", 
            "ChatTellsConsole", "ChatLocalConsole"
        }
        
        for _, consoleName in ipairs(chatItems) do
            if GUI[consoleName] then
                GUI[consoleName]:move(GUI.ChatBox:get_x(), GUI.ChatBox:get_y())
                GUI[consoleName]:resize(GUI.ChatBox:get_width(), GUI.ChatBox:get_height())
            end
        end
    end
    
    -- Update menu consoles
    if GUI.MenuBox then
        local menuItems = {"GroupScrollBox", "PlayersScrollBox", "HelpContainer"}
        
        for _, consoleName in ipairs(menuItems) do
            if GUI[consoleName] then
                GUI[consoleName]:move(GUI.MenuBox:get_x(), GUI.MenuBox:get_y())
                GUI[consoleName]:resize(GUI.MenuBox:get_width(), GUI.MenuBox:get_height())
            end
        end
    end
end

-- Debounced resize handler to prevent excessive updates
function GUI.WindowResize.onWindowResize()
    local w, h = getMainWindowSize()
    
    -- Skip if dimensions haven't actually changed
    if GUI.WindowResize.lastWidth == w and GUI.WindowResize.lastHeight == h then
        return
    end
    
    -- Detect orientation change
    local currentOrientation = w > h and "landscape" or "portrait"
    local orientationChanged = GUI.WindowResize.lastOrientation and 
                              GUI.WindowResize.lastOrientation ~= currentOrientation
    
    GUI.WindowResize.lastWidth = w
    GUI.WindowResize.lastHeight = h
    GUI.WindowResize.lastOrientation = currentOrientation
    
    -- Clear existing timer
    if GUI.WindowResize.resizeTimer then
        killTimer(GUI.WindowResize.resizeTimer)
    end
    
    -- Debounce resize handling
    GUI.WindowResize.resizeTimer = tempTimer(0.1, function()
        GUI.WindowResize.updateBorders()
        GUI.WindowResize.updateGUIElements()
        GUI.WindowResize.adjustLayoutForSize()
        
        if orientationChanged then
            print("Orientation changed to " .. currentOrientation)
            GUI.WindowResize.handleOrientationChange(currentOrientation)
        end
        
        print("GUI layout updated for window size: " .. w .. "x" .. h .. " (" .. currentOrientation .. ")")
    end)
end

-- Handle orientation-specific adjustments
function GUI.WindowResize.handleOrientationChange(orientation)
    if orientation == "portrait" then
        -- Portrait mode: stack elements more vertically
        -- Could potentially rearrange GUI for better portrait viewing
        print("Optimizing layout for portrait orientation")
    else
        -- Landscape mode: use horizontal space efficiently
        print("Optimizing layout for landscape orientation")
    end
end

-- Enhanced sysWindowResizeEvent to make it more responsive
function sysWindowResizeEvent()
    GUI.WindowResize.onWindowResize()
end

-- Function to handle manual GUI refresh
function refreshGUILayout()
    GUI.WindowResize.onWindowResize()
end

-- Initialize responsive layout on first load
function GUI.WindowResize.initialize()
    local w, h = getMainWindowSize()
    GUI.WindowResize.lastWidth = w
    GUI.WindowResize.lastHeight = h
    
    -- Set up initial responsive layout
    GUI.WindowResize.updateBorders()
    GUI.WindowResize.adjustLayoutForSize()
    
    print("Window resize responsiveness initialized for " .. w .. "x" .. h)
end

-- Call initialization
GUI.WindowResize.initialize()
