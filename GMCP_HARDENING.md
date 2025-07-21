# GMCP Hardening Changes - Version 83

## Overview
This version includes comprehensive hardening to prevent runtime errors when GMCP (Generic Mud Communication Protocol) event handler information has not yet been received during script loading.

## Key Changes

### 1. New GMCPSafeAccess.lua Module
- **Location**: `src/scripts/GMCPSafeAccess.lua`
- **Purpose**: Provides safe access to GMCP data with fallback defaults
- **Key Functions**:
  - `GMCPSafe.get(path, defaultValue)` - Safe nested table access
  - `GMCPSafe.exists(path)` - Check if GMCP path exists
  - `GMCPSafe.getNumber(path, defaultValue)` - Safe numeric value retrieval
  - `GMCPSafe.getString(path, defaultValue)` - Safe string value retrieval
  - `GMCPSafe.getTable(path, defaultValue)` - Safe table value retrieval
  - `GMCPSafe.execute(requiredPaths, func, ...)` - Safe function execution wrapper
  - `GMCPSafe.initializeDefaults()` - Initialize default GMCP structure

### 2. Hardened GMCP Access Patterns
All direct `gmcp.X.Y.Z` access patterns have been replaced with safe equivalents:

**Before:**
```lua
local hp = gmcp.Char.Vitals.hp
local name = gmcp.Room.Info.name or "Room"
```

**After:**
```lua
local hp = GMCPSafe.getNumber("Char.Vitals.hp", 0)
local name = GMCPSafe.getString("Room.Info.name", "Room")
```

### 3. Enhanced Error Handling

#### Global GMCP Function Safety
- Added `safeCallGMCPFunction()` wrapper for error-prone GMCP operations
- Enhanced `sendGMCP()` with pcall protection

#### Early Return Guards
Functions now check for incomplete GMCP data and return early:
```lua
if not value or not value.id or not value.name then
  return -- Skip if item data is incomplete
end
```

### 4. Modified Files

#### Core Files:
- `src/scripts/scripts.json` - Added GMCPSafeAccess module
- `src/scripts/Globals.lua` - Added global error handling functions
- `src/scripts/GMCP/Initialize.lua` - Enhanced initialization safety
- `mfile` - Version bumped to 83

#### GMCP Handler Files:
- `src/scripts/GMCP/CharVitals.lua` - Safe vitals access with division-by-zero protection
- `src/scripts/GMCP/CharStatus.lua` - Safe status and equipment access
- `src/scripts/GMCP/RoomInfo.lua` - Safe room information access
- `src/scripts/GMCP/CommChannelText.lua` - Safe channel text with empty text checking
- `src/scripts/GMCP/HelpContainer/CharHelpList.lua` - Safe help list with empty data handling

#### Inventory Management:
- `src/scripts/GMCP/RoomAndInventoryConsoles/Inventory/CharItemsListLocationInv.lua`
- `src/scripts/GMCP/RoomAndInventoryConsoles/Inventory/CharItemsAddLocationInv.lua`
- `src/scripts/GMCP/RoomAndInventoryConsoles/Inventory/CharItemsRemoveLocationInv.lua`
- `src/scripts/GMCP/RoomAndInventoryConsoles/Inventory/CharItemsUpdateLocationInv.lua`

#### Room Management:
- `src/scripts/GMCP/RoomAndInventoryConsoles/Room/UpdateRoomConsole.lua`
- `src/scripts/GMCP/RoomAndInventoryConsoles/Room/Players/RoomAddPlayer.lua`
- `src/scripts/GMCP/RoomAndInventoryConsoles/Room/Players/RoomRemovePlayer.lua`

#### Abilities:
- `src/scripts/GMCP/AbilitiesButtons/CharAbilitiesMonitorRemove.lua`
- `src/scripts/GMCP/AbilitiesButtons/CharAbilitiesMonitorWarn.lua`

#### GUI:
- `src/scripts/GUI/Create_RightContent.lua` - Safe GMCP sending

### 5. Benefits

1. **Startup Resilience**: Scripts load without errors even when GMCP data is not available
2. **Graceful Degradation**: GUI displays default/placeholder values until real data arrives
3. **Division by Zero Protection**: Prevents crashes from zero max values in vitals
4. **Null Reference Protection**: Eliminates nil access errors on nested GMCP tables
5. **Better User Experience**: No more script errors interrupting gameplay

### 6. Backward Compatibility
All changes maintain backward compatibility with existing GMCP event handlers and triggers. The hardening is additive and doesn't change the external API.

### 7. Testing Recommendations
- Test GUI loading before GMCP connection is established
- Verify proper display updates when GMCP data arrives
- Test with partial GMCP data scenarios
- Validate all major GUI components function without errors during startup

## For Developers
When adding new GMCP-dependent functionality:
1. Use `GMCPSafe.*` functions instead of direct `gmcp.*` access
2. Add null/empty checks for incomplete data
3. Provide sensible default values
4. Consider using `GMCPSafe.execute()` for complex operations requiring multiple GMCP paths
