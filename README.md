# Windows Sleep Network Fix

**Automatically reconnect WiFi and Ethernet after Windows sleep/wake cycles**

## The Problem

Does your Windows computer lose network connectivity after waking from sleep? You're not alone! This is an extremely common issue affecting:

- Windows 10 & 11 systems
- Both WiFi and Ethernet connections
- Desktop PCs, laptops, and mini PCs
- Various network adapter brands
- Both battery and AC power modes

**Typical symptoms:**
- Network shows as "connected" but no internet access
- Need to manually disconnect/reconnect WiFi multiple times daily
- Ethernet requires unplugging/replugging cable
- Network troubleshooter temporarily fixes it
- Issue returns after every sleep cycle

## The Solution

This repository provides a **one-click automated solution** that:

- **Automatically reconnects** network adapters when your system wakes
- **Runs on system startup** and wake events via Windows Task Scheduler
- **Releases and renews IP** configurations to reset connections
- **Reconnects to saved WiFi** networks intelligently
- **Restarts network adapters** to ensure clean connections
- **Logs all activity** for troubleshooting
- **Zero maintenance** - set it and forget it

## Quick Start

### Method 1: Batch Script (Recommended)
1. **Download** both `SetupAutoReconnect.bat` and `SetupAutoReconnect.ps1`
2. **Right-click** `SetupAutoReconnect.bat` → **"Run as administrator"**
3. **Done!** Your network will auto-reconnect after every wake cycle

### Method 2: PowerShell Script (Alternative)
1. **Download** `SetupAutoReconnect.ps1`
2. **Right-click** → "Run with PowerShell" **as Administrator**
3. **Done!** Your network will auto-reconnect after every wake cycle

### Upgrading from v1.0?
**No problem!** Just run the v2.0 installer - it will:
- Automatically detect your existing installation
- Upgrade all components with enhanced features
- Preserve your existing logs (with backup)
- Replace the scheduled task with improved settings
- Show you exactly what was upgraded

## What It Does

The setup script automatically:
- Creates an intelligent PowerShell script that handles network reconnection
- Sets up a Windows scheduled task to run on wake/startup/logon
- Provides a manual test script for immediate troubleshooting
- Creates detailed logs with automatic rotation for monitoring
- Tests connectivity before attempting reconnection (avoids unnecessary resets)
- Handles both Wi-Fi and Ethernet connections intelligently
- Includes comprehensive error handling and recovery

## Files Created

- `C:\NetworkReconnect\NetworkReconnect.ps1` - Main reconnection script (enhanced v2.0)
- `C:\NetworkReconnect\RunManually.bat` - Manual testing tool with better UI
- `C:\NetworkReconnect\log.txt` - Activity logs with automatic rotation
- Windows Task: `NetworkReconnectOnWake` - Auto-execution with improved triggers

## Testing & Verification

### Manual Testing
Test the fix before your next sleep cycle:
```batch
C:\NetworkReconnect\RunManually.bat
```

### Check Logs
Monitor what's happening:
```batch
notepad C:\NetworkReconnect\log.txt
```

### Verify Scheduled Task
Check if the task was created successfully:
```cmd
schtasks /query /tn NetworkReconnectOnWake
```

## Easy Uninstall

### Method 1: Batch Uninstaller (Recommended)
1. **Download** `Uninstall.bat`
2. **Right-click** → **"Run as administrator"**
3. **Done!** Everything is removed cleanly

### Method 2: Manual Removal
Remove the scheduled task:
```cmd
schtasks /delete /tn NetworkReconnectOnWake /f
```
Delete the folder: `C:\NetworkReconnect\`

## Troubleshooting

### PowerShell Execution Policy Issues
If you get "execution policy" errors:

**Option 1: Use the Batch Script (Recommended)**
- The `SetupAutoReconnect.bat` automatically bypasses execution policy restrictions

**Option 2: Temporarily Allow Scripts**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Option 3: Run with Bypass**
```powershell
powershell -ExecutionPolicy Bypass -File SetupAutoReconnect.ps1
```

### Script Not Working?
1. **Check the logs**: `C:\NetworkReconnect\log.txt`
2. **Verify task exists**: Run `schtasks /query /tn NetworkReconnectOnWake`
3. **Test manually**: Run `C:\NetworkReconnect\RunManually.bat`
4. **Check Windows Event Viewer** for Task Scheduler errors

### Still Having Issues?
Try these additional manual fixes:
- Disable "Allow computer to turn off this device" in Device Manager
- Set WiFi adapter to "Maximum Performance" in Power Options
- Disable "Energy Efficient Ethernet" in adapter properties
- Update network drivers from manufacturer
- Disable "Fast Startup" in Power Options
- Run Windows Network Troubleshooter

## Contributing

Found a better solution? Have a different use case? PRs welcome! This issue affects millions of Windows users, so every improvement helps.

## Requirements

- **OS**: Windows 10/11 (tested on both)
- **Privileges**: Administrator access (for initial setup only)
- **PowerShell**: Version 5.0+ (included with Windows 10/11)
- **Network**: Works with Wi-Fi, Ethernet, and mixed configurations

## License

MIT License - Use freely, modify as needed

## What's New in Version 2.0

### New Features
- **Batch Script Installer**: Easier installation with automatic elevation
- **Smart Connectivity Testing**: Only runs reconnection when actually needed
- **Enhanced Logging**: Detailed logs with automatic rotation (5MB limit)
- **Better Error Handling**: Comprehensive error recovery and reporting
- **Improved Wi-Fi Handling**: More reliable profile detection and connection
- **Easy Uninstaller**: Clean removal with `Uninstall.bat`
- **Better User Interface**: Colored output and progress indicators

### Technical Improvements
- **Execution Policy Bypass**: Works on restricted corporate systems
- **Enhanced Scheduled Task**: Better triggers and reliability settings
- **Network Adapter Intelligence**: Only restarts physical adapters
- **Connectivity Validation**: Tests internet before and after reconnection
- **Process Isolation**: Better error handling and resource cleanup

---

## Compatibility

** Tested and Working On:**
- Windows 10 (all versions)
- Windows 11 (all versions)
- Intel Wi-Fi adapters (AX200, AX201, AC9560, etc.)
- Realtek Ethernet/Wi-Fi adapters
- Broadcom Wi-Fi adapters
- Qualcomm Wi-Fi adapters
- USB Wi-Fi dongles
- Built-in laptop Wi-Fi
- Desktop PCIe Wi-Fi cards
- Ethernet connections (all brands)

---

** If this solved your network issues, please star the repo to help others find it!**

*Actively maintained and tested on Windows 10/11 with various network configurations.*
