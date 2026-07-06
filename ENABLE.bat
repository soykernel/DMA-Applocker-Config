@echo off
setlocal enabledelayedexpansion

:: Check for administrative privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: You must run this script as an Administrator!
    pause
    exit /b
)

echo =========================================
echo STATUS: RESTORING DEFAULT APPLOCKER
echo =========================================
net stop appidsvc

:: STEP 1: Re-assign ownership back to the SYSTEM user account
icacls "C:\Windows\System32\AppLocker" /setowner "NT AUTHORITY\SYSTEM" /t /c

:: STEP 2: Remove the explicit deny and restore standard system permissions
icacls "C:\Windows\System32\AppLocker" /remove:d SYSTEM /t /c
icacls "C:\Windows\System32\AppLocker" /grant "NT AUTHORITY\SYSTEM":(OI)(CI)(F) /t /c
icacls "C:\Windows\System32\AppLocker" /reset /t /c

:: STEP 3: AUTOMATICALLY GENERATE EVERY VALID DEFAULT RULE COLLECTION (NO SCAN FIXED)
echo Generating default AppLocker policy...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Get-AppLockerPolicy -Local | Set-AppLockerPolicy -Local; " ^
    "$exe = New-AppLockerPolicy -Type Exe -DefaultRules; " ^
    "$msi = New-AppLockerPolicy -Type Msi -DefaultRules; " ^
    "$scr = New-AppLockerPolicy -Type Script -DefaultRules; " ^
    "$app = New-AppLockerPolicy -Type PackagedApp -DefaultRules; " ^
    "Set-AppLockerPolicy -PolicyObject $exe -Merge; " ^
    "Set-AppLockerPolicy -PolicyObject $msi -Merge; " ^
    "Set-AppLockerPolicy -PolicyObject $scr -Merge; " ^
    "Set-AppLockerPolicy -PolicyObject $app -Merge"

:: STEP 4: AUTOMATE APPLOCKER PROPERTIES SCREEN (FORCE ALL 4 TO ENFORCE)
echo Enabling Enforcement Mode for all rule types...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppLocker\Exe" /v "EnforcementMode" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppLocker\Msi" /v "EnforcementMode" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppLocker\Script" /v "EnforcementMode" /t REG_DWORD /d 1 /f >nul
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppLocker\PackagedApp" /v "EnforcementMode" /t REG_DWORD /d 1 /f >nul

:: Clean out the old tracking key if it exists anywhere
reg delete "HKLM\SOFTWARE\AppLockerToggle" /f >nul 2>&1

:: Turn OFF Airplane Mode to restore network adapters
reg add "HKLM\SYSTEM\CurrentControlSet\Control\RadioManagement\SystemRadioState" /v "Pattern" /t REG_DWORD /d 0 /f

:: Ensure Application Identity service is configured to start automatically
sc config appidsvc start= auto

:: Force a standard policy synchronization to commit changes live
gpupdate /target:computer /force

:: Kickstart services
net start appidsvc
net start vgc

echo.
echo AppLocker Setup Re-Built and Enforcement Reactivated Successfully!
pause
exit /b
