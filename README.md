# Windows Debloat & Performance Optimization Script

A comprehensive PowerShell script to debloat Windows 11/10 and optimize system performance while preserving visual animations and essential functionality.

## Features

- **Automatic system restore point creation** for safety and easy rollback
- **Removes 30+ bloatware apps** (Xbox, Your Phone, Bing apps, Office Hub, etc.)
- **Disables 15+ unnecessary services** (Telemetry, Windows Search, WSL, Gaming Services)
- **Registry optimizations** for memory management and CPU priority
- **Network and power optimizations** for better performance
- **Disables Windows Search and indexing** completely
- **SSD optimization** with TRIM enabled
- **Automatic temp file cleanup**
- **Memory usage reporting** before and after optimization

## Performance Gains

- **Reduces idle RAM usage by 1-2GB** (from ~6GB to 4-5GB system usage)
- **Faster boot times** with disabled startup services
- **Lower background CPU usage** with telemetry disabled
- **Improved responsiveness** with optimized memory management
- **Preserves visual effects and animations** unlike other debloat scripts

## Quick Start

1. **Download the script** or clone this repository
2. **Right-click** `windows-debloat-script.ps1` → **Run with PowerShell (Admin)**
3. **Script automatically creates a system restore point** for safety
4. **Follow the prompts** and wait for completion
5. **Restart your computer** for all changes to take effect

```powershell
# Or run from Admin PowerShell
.\windows-debloat-script.ps1
```

## What Gets Removed/Disabled

### Bloatware Apps Removed
- Xbox Game Bar, Xbox services
- Your Phone, Phone Link
- Bing Weather, News, Search
- 3D Viewer, Mixed Reality Portal
- Solitaire Collection, Candy Crush
- Skype, Messaging apps
- Office Hub, Get Help, Tips
- And many more...

### Services Disabled
- **DiagTrack** - Telemetry and diagnostics
- **WSearch** - Windows Search and indexing
- **WSLService** - Windows Subsystem for Linux
- **dmwappushservice** - WAP push message routing
- **MapsBroker** - Downloaded maps manager
- **PhoneSvc** - Phone connectivity service
- **QWAVE** - Quality Windows Audio Video Experience
- **FileSyncHelper** - OneDrive file sync helper
- And more...

### Windows Features Disabled
- Windows Subsystem for Linux (WSL)
- Virtual Machine Platform
- Search Engine Client Package
- Work Folders Client
- Internet Printing Client

## Registry Optimizations

- Disables telemetry and data collection
- Optimizes memory management (paging, cache)
- Sets CPU priority for better responsiveness
- Disables background apps globally
- Removes startup delays
- Disables Windows Tips and suggestions
- Optimizes NTFS file system performance

## Important Notes

- **Administrator privileges required**
- **System restore point automatically created** before modifications
- **Restart needed** for all changes to take effect
- **Windows Search will be disabled** (no file search from Start Menu)
- **Some UI processes may restart automatically**
- **WSL will be completely removed** (Docker Desktop may be affected)
- **Compatible with Windows 10 and 11**

## Reversibility

Most changes can be reversed by:
- **Using the automatically created system restore point** (easiest method)
- Re-enabling services through Services.msc
- Re-enabling Windows features through "Turn Windows features on or off"
- Reinstalling apps from Microsoft Store
- Modifying registry values back to defaults

## Before/After Comparison

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| Idle RAM Usage | ~6-7GB | ~4-5GB | 1-2GB saved |
| Boot Time | Standard | Faster | Services reduced |
| Background CPU | High | Low | Telemetry disabled |
| Storage Usage | Bloated | Clean | Apps removed |

## Contributing

Feel free to:
- Report issues or bugs
- Suggest improvements
- Submit pull requests
- Share your performance results

## License

This project is open source and available under the [MIT License](LICENSE).

## System Requirements

- Windows 10 (1903+) or Windows 11
- PowerShell 5.1 or later
- Administrator privileges
- At least 4GB RAM (8GB+ recommended)

## Changelog

### v1.0.0
- Initial release
- Complete debloat and optimization suite
- Memory usage optimization
- Service and feature management
- Registry tweaks for performance

---

**Disclaimer**: This script modifies system settings and removes Windows components. A system restore point is automatically created for safety, but use at your own risk.