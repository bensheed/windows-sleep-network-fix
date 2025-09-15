# Setup Script for Auto Network Reconnect on Wake
# Run this as Administrator to set up automatic network reconnection
# Save as SetupAutoReconnect.ps1

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires administrator privileges. Please run as Administrator." -ForegroundColor Red
    Write-Host "Press any key to exit..." -ForegroundColor White
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host "Setting up Auto Network Reconnect..." -ForegroundColor Green

# Create directory for scripts
$scriptDir = "C:\NetworkReconnect"
if (!(Test-Path $scriptDir)) {
    New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
}

# Create the main network reconnect script
$networkScript = @'
# Network Reconnect Script for Wake Issues
Write-Host "$(Get-Date): Network Reconnect Script Starting..." | Out-File "C:\NetworkReconnect\log.txt" -Append

try {
    # Release and renew IP
    ipconfig /release | Out-Null
    Start-Sleep -Seconds 2
    ipconfig /renew | Out-Null
    Start-Sleep -Seconds 3
    
    # Reconnect Wi-Fi
    $profiles = netsh wlan show profiles | Select-String "All User Profile" | ForEach-Object { ($_ -split ": ")[1].Trim() }
    
    if ($profiles) {
        netsh wlan disconnect | Out-Null
        Start-Sleep -Seconds 2
        
        foreach ($profile in $profiles) {
            $result = netsh wlan connect name="$profile" 2>&1
            if ($result -notmatch "failed") {
                Write-Host "$(Get-Date): Connected to $profile" | Out-File "C:\NetworkReconnect\log.txt" -Append
                break
            }
        }
    }
    
    # Reset adapters
    Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Restart-NetAdapter -Confirm:$false -ErrorAction SilentlyContinue
    
    Write-Host "$(Get-Date): Network reset completed" | Out-File "C:\NetworkReconnect\log.txt" -Append
    
} catch {
    Write-Host "$(Get-Date): Error - $($_.Exception.Message)" | Out-File "C:\NetworkReconnect\log.txt" -Append
}
'@

$networkScript | Out-File "$scriptDir\NetworkReconnect.ps1" -Encoding UTF8

# Create scheduled task to run on wake
Write-Host "Creating scheduled task..." -ForegroundColor Yellow

# Remove existing task if it exists
Unregister-ScheduledTask -TaskName "NetworkReconnectOnWake" -Confirm:$false -ErrorAction SilentlyContinue

# Create new task
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$scriptDir\NetworkReconnect.ps1`""

# Create trigger for system wake
$trigger1 = New-ScheduledTaskTrigger -AtStartup
$trigger2 = New-ScheduledTaskTrigger -AtLogOn

# Create settings
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# Create principal (run as SYSTEM)
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

# Register the task
Register-ScheduledTask -TaskName "NetworkReconnectOnWake" -Action $action -Trigger $trigger1, $trigger2 -Settings $settings -Principal $principal -Description "Reconnects network adapters after system wake"

# Also create a manual run batch file for testing
$batchContent = @'
@echo off
echo Running Network Reconnect Script...
powershell.exe -WindowStyle Normal -ExecutionPolicy Bypass -File "C:\NetworkReconnect\NetworkReconnect.ps1"
pause
'@

$batchContent | Out-File "$scriptDir\RunManually.bat" -Encoding ASCII

Write-Host "`nSetup completed successfully!" -ForegroundColor Green
Write-Host "`nFiles created:" -ForegroundColor White
Write-Host "- Main script: $scriptDir\NetworkReconnect.ps1" -ForegroundColor Gray
Write-Host "- Manual runner: $scriptDir\RunManually.bat" -ForegroundColor Gray
Write-Host "- Log file will be: $scriptDir\log.txt" -ForegroundColor Gray
Write-Host "`nScheduled task 'NetworkReconnectOnWake' has been created." -ForegroundColor White
Write-Host "`nTo test manually, run: $scriptDir\RunManually.bat" -ForegroundColor Cyan
Write-Host "`nTo remove this setup later, run: schtasks /delete /tn NetworkReconnectOnWake /f" -ForegroundColor Gray

Write-Host "`nPress any key to exit..." -ForegroundColor White
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")