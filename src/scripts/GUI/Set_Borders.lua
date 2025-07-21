-- Enhanced responsive border setting
local w, h = getMainWindowSize()

-- Set initial borders with responsive calculations
setBorderLeft(0)
setBorderTop(math.max(30, h/20))  -- Minimum 30px for header
setBorderBottom(math.max(50, h/10))  -- Minimum 50px for footer  
setBorderRight(math.max(200, w/2.5))  -- Minimum 200px for right panel

-- Store original border function for manual refresh
if not originalSetBorders then
    originalSetBorders = function()
        local w, h = getMainWindowSize()
        setBorderLeft(0)
        setBorderTop(math.max(30, h/20))
        setBorderBottom(math.max(50, h/10))
        setBorderRight(math.max(200, w/2.5))
    end
end