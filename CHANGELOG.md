# Changelog

All notable changes to this project will be documented in this file.

## [82] - 2025-07-21

### Added
- **GMCPSafeAccess.lua**: Safe GMCP data access utility with fallback defaults
- **WindowResize.lua**: Enhanced responsive window resizing system
- Global error handling for GMCP functions with pcall protection

### Changed
- All GMCP handlers now use safe access patterns instead of direct `gmcp.*` access
- Updated 20+ files including CharVitals, CharStatus, inventory handlers, and room management
- Enhanced GUI positioning to be more responsive to window resizing
- Version bumped from 81 to 82

### Fixed
- Runtime errors when GMCP data unavailable during script loading
- Division by zero crashes in character vitals calculations
- Nil access errors on nested GMCP tables
- Missing data handling throughout GMCP handlers
