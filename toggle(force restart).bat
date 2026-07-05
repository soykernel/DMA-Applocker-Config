@echo off
setlocal enabledelayedexpansion

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: You must run this script as an Administrator!
    pause
    exit /b
)

:: Define the memory flag outside the targeted directory
set "FLAG_FILE=C:\Windows\System32\toggle_applocker_state.txt"

if exist "%FLAG_FILE%" (
    goto TURN_ON
) else (
    goto TURN_OFF
)

:TURN_OFF
echo =========================================
echo TOGGLING STATUS: DEACTIVATING APPLOCKER
echo =========================================
net stop appidsvc

:: Delete policy files
del /f /s /q "C:\Windows\System32\AppLocker\*. *"

:: Break cache file locks natively using your verified method
takeown /f "C:\Windows\System32\AppLocker\AppCache.dat" /a
icacls "C:\Windows\System32\AppLocker\AppCache.dat" /grant administrators:F
del /f /q "C:\Windows\System32\AppLocker\AppCache.dat"

:: WIPE local registry backups
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\SrpV2" /f
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppLocker" /f

:: Lock down permissions to prevent restoration
takeown /f "C:\Windows\System32\AppLocker" /r /d y
icacls "C:\Windows\System32\AppLocker" /grant administrators:F /t
icacls "C:\Windows\System32\AppLocker" /deny SYSTEM:(OI)(CI)(W)

:: Drop memory tracker
echo Bypassed > "%FLAG_FILE%"

echo.
echo Enabling Airplane mode and restarting to apply changes...
:: Turn ON Airplane Mode
reg add "HKLM\SYSTEM\CurrentControlSet\Control\RadioManagement\SystemRadioState" /v "Pattern" /t REG_DWORD /d 1 /f

:: Force immediate computer restart
shutdown /r /t 3 /f
exit /b

:TURN_ON
echo =========================================
echo TOGGLING STATUS: RESTORING DEFAULT APPLOCKER
echo =========================================
net stop appidsvc

:: Strip the system lockout rule
icacls "C:\Windows\System32\AppLocker" /remove:deny SYSTEM /t

:: Erase the tracker
del /f /q "%FLAG_FILE%"

:: Force a standard policy synchronization
gpupdate /target:computer /force

:: Turn OFF Airplane Mode
reg add "HKLM\SYSTEM\CurrentControlSet\Control\RadioManagement\SystemRadioState" /v "Pattern" /t REG_DWORD /d 0 /f

:: Kickstart services
net start appidsvc
net start vgc

echo.
echo AppLocker Defaults Restored Successfully!
pause
exit /b
