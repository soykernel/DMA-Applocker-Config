# DMA-Applocker-Config
A .bat utility to adjust MDM policies, to toggle unblocking of apps across sessions. REQUIRES ADMIN.

## Operational User Manual## Critical Prerequisites

* Elevation Required: Both scripts manipulate root system directories and hardware registry states. They must be executed by right-clicking the file and selecting Run as Administrator.
* Forced Interruption Notice: The deactivation script will sever your internet connection and restart your computer within 3 seconds. Save all active documents, browser tabs, or game sessions before execution.

------------------------------
## Step-by-Step Usage Instructions## Phase 1: Bypassing Restrictions (Unlocking Your Apps)

   1. Close all active programs, projects, and work folders.
   2. Right-click DISABLE.bat and select Run as Administrator.
   3. The Command Prompt console will flash, wipe active rules, engage Airplane Mode, and immediately restart your machine.
   4. Log back into Windows. Your computer will be completely offline, and all previously blocked applications (such as Opera GX, alternate game launchers, or mod tools) will launch and execute freely.

## Phase 2: Restoring System Defense (Locking Apps Back Down)

   1. When you are finished using your unblocked software, close your applications.
   2. Right-click ENABLE and select Run as Administrator.
   3. A clean console stream will instantly compile default whitelists, reset folder permissions, wake your network hardware back up, and execute a Group Policy sync.
      (This step will likely trigger a few error messages on the console. This is perfectly normal and does not affect the intended outcome.)
   5. No restart is required. All third-party applications outside of official Windows system paths will instantly be blocked on your live desktop session.


## Windows AppLocker Bypass & Enforcement Framework
This dual-script infrastructure acts as an administrative toggle killswitch for Windows AppLocker. It bypasses structural application security controls natively without modifying original system files, allowing software to run, and seamlessly locks the machine back down when finished.

------------------------------

## Code Structural Analysis## 1. The AppLocker Disabler (DISABLE.bat)
This script forces a localised system security freeze through aggressive kernel file interventions and temporary network isolation.

* Service & File-Handle Sabotage: Terminating the active Application Identity service (appidsvc) allows the script to seize file ownership (takeown) and force full access permissions (icacls) over the primary policy cache (AppCache.dat), breaking active file locks to wipe old rule logs.
* Registry Purge: Deletes local software restriction hives (SrpV2 and AppLocker) directly from the registry, stripping out custom administrative block configurations.
* Access Control Lockdown: Injects an explicit icacls ... /deny SYSTEM rule on the master folder. This creates a hard folder lock that blocks the operating system from re-syncing or re-writing security rules.
* Air-Gap Isolation & Forced Reboot: Toggles a hardware Airplane Mode override (SystemRadioState -> 1) to drop all active network handshakes. It then instantly commands a forced restart (shutdown /r /t 3 /f) to flush system memory caches, leaving the PC to boot up entirely offline and free of AppLocker enforcement.

## 2. The AppLocker Enforcer (ENABLE.bat)
This script clears the directory lockdown state and seamlessly restores the default Windows security baseline.

* Inheritance & Identity Repair: Hands folder ownership directly back to the core operational engine (NT AUTHORITY\SYSTEM) and strips out the explicit denial rule via the /remove:d switch.
* Programmatic Policy Compilation: Spawns a high-speed, elevated PowerShell pipeline that utilizes native Microsoft deployment cmdlets (New-AppLockerPolicy -DefaultRules). This cleanly compiles a clean, default Allow whitelist framework for Executables, MSIs, Scripts, and Packaged Apps in memory without performing slow local disk sector sweeps.
* Registry Enforcement & Network Wakeup: Writes active enforcement flags (EnforcementMode = 1) back to the registry, switching all rule categories to active protection. It deactivates Airplane Mode to reconnect local Wi-Fi/Ethernet adapters, configures appidsvc back to start automatically, and invokes gpupdate /force to commit the security blocks live.

------------------------------


# DISCLAIMER
WE ARE AN INDEPENDENT ORGANISATION AND ARE NOT AFFILIATED WITH THE MINISTRY OF EDUCATION (MOE) OR ANY OTHER GOVERNMENTAL OR EDUCATIONAL INSTITUTIONS. PLEASE NOTE THAT WE ARE NOT LIABLE FOR ANY CONSEQUENCES RESULTING FROM THE MISUSE OF YOUR PERSONAL LEARNING DEVICES (PLDS). IT IS YOUR RESPONSIBILITY TO ADHERE TO YOUR SCHOOL’S GUIDELINES AND REGULATIONS REGARDING THE USE OF THESE DEVICES. ANY INAPPROPRIATE OR UNAUTHORIZED USE THAT LEADS TO DISCIPLINARY ACTIONS OR OTHER CONSEQUENCES IS SOLELY YOUR RESPONSIBILITY. WE STRONGLY ENCOURAGE USERS TO COMPLY WITH THEIR INSTITUTION’S POLICIES TO AVOID SUCH ISSUES. THIS IS PURELY MEANT FOR EDUCATIONAL PURPOSES ONLY.
