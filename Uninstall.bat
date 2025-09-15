@echo off
:: Windows Sleep Network Fix - Uninstaller
:: Removes the scheduled task and network reconnect files

title Windows Sleep Network Fix - Uninstall

:: Check if running as administrator
net session >nul 2>&1
if %errorLevel% == 0 (
    echo Running with administrator privileges...
    goto :run_uninstall
)

:: Not running as admin, attempt to elevate
echo.
echo ========================================
echo  Windows Sleep Network Fix - Uninstall
echo ========================================
echo.
echo This script needs administrator privileges to:
echo - Remove Windows scheduled tasks
echo - Delete system network scripts
echo.
echo Requesting administrator privileges...
echo.

:: Try to elevate using PowerShell
powershell -Command "Start-Process '%~f0' -Verb RunAs" 2>nul
if %errorLevel% == 0 (
    echo Elevation request sent. Please check for UAC prompt.
    timeout /t 3 >nul
    exit /b 0
) else (
    echo Failed to request elevation. Please run as administrator manually.
    pause
    exit /b 1
)

:run_uninstall
echo.
echo ========================================
echo  Uninstalling Network Sleep Fix
echo ========================================
echo.

set "SCRIPT_DIR=C:\NetworkReconnect"
set "TASK_NAME=NetworkReconnectOnWake"

:: Remove scheduled task
echo Removing scheduled task "%TASK_NAME%"...
schtasks /delete /tn "%TASK_NAME%" /f >nul 2>&1
if %errorLevel% == 0 (
    echo ✓ Scheduled task removed successfully
) else (
    echo ⚠ Scheduled task not found or already removed
)

:: Remove script directory and files
echo.
echo Removing script files from %SCRIPT_DIR%...
if exist "%SCRIPT_DIR%" (
    rmdir /s /q "%SCRIPT_DIR%" >nul 2>&1
    if %errorLevel% == 0 (
        echo ✓ Script directory removed successfully
    ) else (
        echo ⚠ Could not remove script directory completely
        echo   You may need to manually delete: %SCRIPT_DIR%
    )
) else (
    echo ⚠ Script directory not found or already removed
)

:: Check if uninstall was successful
echo.
echo ========================================
echo  Uninstall Status Check
echo ========================================
echo.

:: Check if task still exists
schtasks /query /tn "%TASK_NAME%" >nul 2>&1
if %errorLevel% == 0 (
    echo ❌ Scheduled task still exists
    set "UNINSTALL_SUCCESS=false"
) else (
    echo ✓ Scheduled task successfully removed
)

:: Check if directory still exists
if exist "%SCRIPT_DIR%" (
    echo ❌ Script directory still exists: %SCRIPT_DIR%
    set "UNINSTALL_SUCCESS=false"
) else (
    echo ✓ Script directory successfully removed
)

echo.
if "%UNINSTALL_SUCCESS%"=="false" (
    echo ========================================
    echo  Partial Uninstall - Manual Cleanup
    echo ========================================
    echo.
    echo Some components could not be automatically removed.
    echo Please manually complete the uninstall:
    echo.
    echo 1. Remove scheduled task:
    echo    schtasks /delete /tn "%TASK_NAME%" /f
    echo.
    echo 2. Delete script directory:
    echo    rmdir /s /q "%SCRIPT_DIR%"
    echo.
) else (
    echo ========================================
    echo  Uninstall Completed Successfully!
    echo ========================================
    echo.
    echo The Windows Sleep Network Fix has been completely removed.
    echo Your system will no longer automatically reconnect networks after sleep.
    echo.
    echo If you experience network issues after sleep, you can:
    echo 1. Reinstall this fix using SetupAutoReconnect.bat
    echo 2. Try the manual solutions mentioned in the README
    echo.
)

echo Press any key to exit...
pause >nul
exit /b 0