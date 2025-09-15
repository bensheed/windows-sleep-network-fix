# Windows Sleep Network Fix

**Automatically reconnect WiFi and Ethernet after Windows sleep/wake cycles**

## 🚨 The Problem

Does your Windows computer lose network connectivity after waking from sleep? You're not alone! This is an extremely common issue affecting:

- ✅ Windows 10 & 11 systems
- ✅ Both WiFi and Ethernet connections  
- ✅ Desktop PCs, laptops, and mini PCs
- ✅ Various network adapter brands
- ✅ Both battery and AC power modes

**Typical symptoms:**
- Network shows as "connected" but no internet access
- Need to manually disconnect/reconnect WiFi multiple times daily
- Ethernet requires unplugging/replugging cable
- Network troubleshooter temporarily fixes it
- Issue returns after every sleep cycle

## 💡 The Solution

This repository provides a **one-click automated solution** that:

- 🔄 **Automatically reconnects** network adapters when your system wakes
- 📋 **Runs on system startup** and wake events via Windows Task Scheduler
- 🔧 **Releases and renews IP** configurations to reset connections
- 📶 **Reconnects to saved WiFi** networks intelligently
- 🌐 **Restarts network adapters** to ensure clean connections
- 📝 **Logs all activity** for troubleshooting
- ⚡ **Zero maintenance** - set it and forget it

## 🚀 Quick Start

1. **Download** `SetupAutoReconnect.ps1`
2. **Right-click** → "Run with PowerShell" **as Administrator**
3. **Done!** Your network will auto-reconnect after every wake cycle

## 🛠️ What It Does

The setup script automatically:
- Creates a PowerShell script that handles network reconnection
- Sets up a Windows scheduled task to run on wake/startup
- Provides a manual test script for immediate troubleshooting
- Creates detailed logs for monitoring

## 📁 Files Created

- `C:\NetworkReconnect\NetworkReconnect.ps1` - Main reconnection script
- `C:\NetworkReconnect\RunManually.bat` - Manual testing tool
- `C:\NetworkReconnect\log.txt` - Activity logs
- Windows Task: `NetworkReconnectOnWake` - Auto-execution

## 🔧 Manual Testing

Test the fix before your next sleep cycle:
```
C:\NetworkReconnect\RunManually.bat
```

## 🗑️ Uninstall

Remove the scheduled task:
```cmd
schtasks /delete /tn NetworkReconnectOnWake /f
```
Delete the folder: `C:\NetworkReconnect\`

## 🆘 Alternative Solutions

If the automatic script doesn't work, try these manual fixes:
- Disable "Allow computer to turn off this device" in Device Manager
- Set WiFi adapter to "Maximum Performance" in Power Options
- Disable "Energy Efficient Ethernet" in adapter properties
- Update network drivers from manufacturer

## 🤝 Contributing

Found a better solution? Have a different use case? PRs welcome! This issue affects millions of Windows users, so every improvement helps.

## ⚠️ Requirements

- Windows 10/11
- Administrator privileges (for initial setup only)
- PowerShell execution policy allowing scripts

## 📝 License

MIT License - Use freely, modify as needed

---

**★ If this solved your network issues, please star the repo to help others find it!**

*Tested on Windows 10/11 with various network adapters including Intel, Realtek, Broadcom, and Qualcomm chips.*
