# Windows Sleep Network Fix - Setup Script
# Automatically reconnects network adapters after Windows sleep/wake cycles
# Version: 2.0
# Run this as Administrator to set up automatic network reconnection

param(
    [switch]$Silent = $false
)

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White",
        [switch]$NoNewline
    )
    if (-not $Silent) {
        if ($NoNewline) {
            Write-Host $Message -ForegroundColor $Color -NoNewline
        } else {
            Write-Host $Message -ForegroundColor $Color
        }
    }
}

# Function to log messages with timestamp
function Write-LogMessage {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-ColorOutput $logMessage
}

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-ColorOutput "ERROR: This script requires administrator privileges." -Color Red
    Write-ColorOutput "Please run as Administrator using one of these methods:" -Color Yellow
    Write-ColorOutput "1. Right-click SetupAutoReconnect.bat and select 'Run as administrator'" -Color Gray
    Write-ColorOutput "2. Right-click SetupAutoReconnect.ps1 and select 'Run with PowerShell' as Administrator" -Color Gray
    Write-ColorOutput "3. Run from an elevated PowerShell prompt" -Color Gray
    if (-not $Silent) {
        Write-ColorOutput "`nPress any key to exit..." -Color White
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    exit 1
}

Write-LogMessage "Starting Windows Sleep Network Fix setup..." "INFO"

# Create directory for scripts
$scriptDir = "C:\NetworkReconnect"
Write-LogMessage "Creating script directory: $scriptDir" "INFO"

try {
    if (!(Test-Path $scriptDir)) {
        New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
        Write-LogMessage "Script directory created successfully" "INFO"
    } else {
        Write-LogMessage "Script directory already exists" "INFO"
    }
} catch {
    Write-LogMessage "Failed to create script directory: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Create the main network reconnect script with improved error handling
Write-LogMessage "Creating network reconnection script" "INFO"

$networkScript = @'
# Windows Sleep Network Fix - Network Reconnection Script
# Version: 2.0
# This script runs automatically after system wake to fix network connectivity

$logFile = "C:\NetworkReconnect\log.txt"
$maxLogSize = 5MB

# Function to write log with rotation
function Write-NetworkLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Rotate log if too large
    if ((Test-Path $logFile) -and (Get-Item $logFile).Length -gt $maxLogSize) {
        if (Test-Path "$logFile.old") { Remove-Item "$logFile.old" -Force }
        Rename-Item $logFile "$logFile.old" -Force
    }
    
    $logEntry | Out-File $logFile -Append -Encoding UTF8
}

Write-NetworkLog "Network Reconnect Script Starting (PID: $PID)" "INFO"

try {
    # Check network connectivity first
    $internetTest = Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($internetTest) {
        Write-NetworkLog "Internet connectivity already working, skipping reconnection" "INFO"
        exit 0
    }
    
    Write-NetworkLog "No internet connectivity detected, starting network reset" "WARN"
    
    # Step 1: Release and renew IP configuration
    Write-NetworkLog "Releasing IP configuration..." "INFO"
    $releaseResult = ipconfig /release 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-NetworkLog "IP release successful" "INFO"
    } else {
        Write-NetworkLog "IP release failed: $releaseResult" "WARN"
    }
    
    Start-Sleep -Seconds 3
    
    Write-NetworkLog "Renewing IP configuration..." "INFO"
    $renewResult = ipconfig /renew 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-NetworkLog "IP renewal successful" "INFO"
    } else {
        Write-NetworkLog "IP renewal failed: $renewResult" "WARN"
    }
    
    Start-Sleep -Seconds 3
    
    # Step 2: Handle Wi-Fi reconnection
    Write-NetworkLog "Checking Wi-Fi profiles..." "INFO"
    $wlanProfiles = @()
    
    try {
        $profileOutput = netsh wlan show profiles 2>&1
        if ($LASTEXITCODE -eq 0) {
            $wlanProfiles = $profileOutput | Select-String "All User Profile" | ForEach-Object { 
                ($_ -split ": ")[1].Trim().Trim('"') 
            } | Where-Object { $_ -and $_.Length -gt 0 }
            Write-NetworkLog "Found $($wlanProfiles.Count) Wi-Fi profiles" "INFO"
        }
    } catch {
        Write-NetworkLog "Failed to get Wi-Fi profiles: $($_.Exception.Message)" "WARN"
    }
    
    if ($wlanProfiles.Count -gt 0) {
        Write-NetworkLog "Disconnecting from current Wi-Fi..." "INFO"
        netsh wlan disconnect 2>&1 | Out-Null
        Start-Sleep -Seconds 3
        
        foreach ($profile in $wlanProfiles) {
            Write-NetworkLog "Attempting to connect to: $profile" "INFO"
            $connectResult = netsh wlan connect name="$profile" 2>&1
            
            if ($connectResult -notmatch "failed|error" -and $LASTEXITCODE -eq 0) {
                Write-NetworkLog "Successfully connected to: $profile" "INFO"
                Start-Sleep -Seconds 5
                break
            } else {
                Write-NetworkLog "Failed to connect to $profile`: $connectResult" "WARN"
            }
        }
    }
    
    # Step 3: Restart network adapters
    Write-NetworkLog "Restarting active network adapters..." "INFO"
    try {
        $activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.Virtual -eq $false }
        foreach ($adapter in $activeAdapters) {
            Write-NetworkLog "Restarting adapter: $($adapter.Name)" "INFO"
            Restart-NetAdapter -Name $adapter.Name -Confirm:$false -ErrorAction SilentlyContinue
        }
        Start-Sleep -Seconds 5
    } catch {
        Write-NetworkLog "Error restarting adapters: $($_.Exception.Message)" "ERROR"
    }
    
    # Step 4: Final connectivity test
    Start-Sleep -Seconds 5
    $finalTest = Test-NetConnection -ComputerName "8.8.8.8" -Port 53 -InformationLevel Quiet -WarningAction SilentlyContinue
    if ($finalTest) {
        Write-NetworkLog "Network reconnection successful - Internet connectivity restored" "INFO"
    } else {
        Write-NetworkLog "Network reconnection completed but connectivity test failed" "WARN"
    }
    
} catch {
    Write-NetworkLog "Critical error in network reconnection: $($_.Exception.Message)" "ERROR"
    Write-NetworkLog "Stack trace: $($_.ScriptStackTrace)" "ERROR"
} finally {
    Write-NetworkLog "Network Reconnect Script completed" "INFO"
}
'@

try {
    $networkScript | Out-File "$scriptDir\NetworkReconnect.ps1" -Encoding UTF8
    Write-LogMessage "Network reconnection script created successfully" "INFO"
} catch {
    Write-LogMessage "Failed to create network script: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Create scheduled task to run on wake
Write-LogMessage "Creating scheduled task..." "INFO"

try {
    # Remove existing task if it exists
    $existingTask = Get-ScheduledTask -TaskName "NetworkReconnectOnWake" -ErrorAction SilentlyContinue
    if ($existingTask) {
        Write-LogMessage "Removing existing scheduled task" "INFO"
        Unregister-ScheduledTask -TaskName "NetworkReconnectOnWake" -Confirm:$false
    }

    # Create new task with improved triggers
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -NoProfile -File `"$scriptDir\NetworkReconnect.ps1`""

    # Create multiple triggers for better coverage
    $trigger1 = New-ScheduledTaskTrigger -AtStartup
    $trigger2 = New-ScheduledTaskTrigger -AtLogOn
    
    # Create a custom trigger for system wake (Event ID 1 from Kernel-Power source)
    $triggerClass = Get-CimClass -ClassName MSFT_TaskEventTrigger -Namespace Root/Microsoft/Windows/TaskScheduler:MSFT_TaskEventTrigger
    $trigger3 = New-CimInstance -CimClass $triggerClass -ClientOnly
    $trigger3.Subscription = "<QueryList><Query Id='0' Path='System'><Select Path='System'>*[System[Provider[@Name='Microsoft-Windows-Power-Troubleshooter'] and EventID=1]]</Select></Query></QueryList>"
    $trigger3.Enabled = $true

    # Create settings with better reliability
    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -RunOnlyIfNetworkAvailable:$false -WakeToRun
    $settings.ExecutionTimeLimit = "PT5M"  # 5 minute timeout
    $settings.RestartCount = 3
    $settings.RestartInterval = "PT1M"

    # Create principal (run as SYSTEM with highest privileges)
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

    # Register the task
    Register-ScheduledTask -TaskName "NetworkReconnectOnWake" -Action $action -Trigger $trigger1, $trigger2 -Settings $settings -Principal $principal -Description "Automatically reconnects network adapters after system wake to fix connectivity issues"
    
    Write-LogMessage "Scheduled task created successfully" "INFO"
    
} catch {
    Write-LogMessage "Failed to create scheduled task: $($_.Exception.Message)" "ERROR"
    Write-LogMessage "You may need to create the task manually or check Windows Task Scheduler permissions" "WARN"
}

# Create improved manual test batch file
Write-LogMessage "Creating manual test batch file" "INFO"

$batchContent = @'
@echo off
title Windows Sleep Network Fix - Manual Test
echo.
echo ========================================
echo  Windows Sleep Network Fix - Manual Test
echo ========================================
echo.
echo This will run the network reconnection script manually.
echo You can use this to test if the fix works before your next sleep cycle.
echo.
echo Running Network Reconnect Script...
echo.
powershell.exe -WindowStyle Normal -ExecutionPolicy Bypass -NoProfile -File "C:\NetworkReconnect\NetworkReconnect.ps1"
echo.
echo ========================================
echo  Test completed!
echo ========================================
echo.
echo Check the log file for details: C:\NetworkReconnect\log.txt
echo.
pause
'@

try {
    $batchContent | Out-File "$scriptDir\RunManually.bat" -Encoding ASCII
    Write-LogMessage "Manual test batch file created successfully" "INFO"
} catch {
    Write-LogMessage "Failed to create manual test batch file: $($_.Exception.Message)" "WARN"
}

# Display completion summary
Write-ColorOutput "`n========================================" -Color Green
Write-ColorOutput "  Setup Completed Successfully!" -Color Green
Write-ColorOutput "========================================" -Color Green

Write-ColorOutput "`nFiles created in $scriptDir`:" -Color White
Write-ColorOutput "✓ NetworkReconnect.ps1 - Main reconnection script" -Color Gray
Write-ColorOutput "✓ RunManually.bat - Manual testing tool" -Color Gray
Write-ColorOutput "✓ log.txt - Activity logs (created on first run)" -Color Gray

Write-ColorOutput "`nScheduled Task:" -Color White
Write-ColorOutput "✓ 'NetworkReconnectOnWake' - Runs automatically on startup/logon" -Color Gray

Write-ColorOutput "`nNext Steps:" -Color Cyan
Write-ColorOutput "1. Test the fix: Run $scriptDir\RunManually.bat" -Color White
Write-ColorOutput "2. Put your computer to sleep and wake it to test automatic operation" -Color White
Write-ColorOutput "3. Check logs at: $scriptDir\log.txt" -Color White

Write-ColorOutput "`nUninstall Instructions:" -Color Yellow
Write-ColorOutput "• Use the provided Uninstall.bat script, or" -Color Gray
Write-ColorOutput "• Run: schtasks /delete /tn NetworkReconnectOnWake /f" -Color Gray
Write-ColorOutput "• Delete folder: $scriptDir" -Color Gray

Write-ColorOutput "`nYour network will now automatically reconnect after sleep/wake cycles!" -Color Green

if (-not $Silent) {
    Write-ColorOutput "`nPress any key to exit..." -Color White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}