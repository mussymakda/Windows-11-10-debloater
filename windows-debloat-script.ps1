# Windows Debloat and Performance Optimization Script
# Run as Administrator
# This script removes bloatware, disables unnecessary services, and optimizes performance

Write-Host "Starting Windows Debloat and Optimization..." -ForegroundColor Green

# Check if running as administrator
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script requires Administrator privileges. Please run as Administrator." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

Write-Host "Creating system restore point..." -ForegroundColor Yellow

# Enable System Restore if disabled
try {
    Enable-ComputerRestore -Drive "C:\" -ErrorAction Stop
    Write-Host "System Restore enabled for C: drive" -ForegroundColor Green
}
catch {
    Write-Host "System Restore already enabled or cannot be enabled" -ForegroundColor Gray
}

# Create restore point
try {
    Checkpoint-Computer -Description "Before Windows Debloat Script - $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
    Write-Host "System restore point created successfully" -ForegroundColor Green
}
catch {
    Write-Host "Warning: Could not create restore point automatically" -ForegroundColor Yellow
    Write-Host "You may need to enable System Restore in System Properties" -ForegroundColor Yellow
    $continue = Read-Host "Continue without restore point? (y/N)"
    if ($continue -ne 'y' -and $continue -ne 'Y') {
        Write-Host "Operation cancelled by user." -ForegroundColor Red
        Read-Host "Press Enter to exit"
        exit
    }
}

Write-Host "Step 1: Removing bloatware apps..." -ForegroundColor Yellow

# Remove bloatware apps
$bloatwareApps = @(
    "*Microsoft.BingWeather*",
    "*Microsoft.GetHelp*", 
    "*Microsoft.Getstarted*",
    "*Microsoft.Messaging*",
    "*Microsoft.MicrosoftOfficeHub*",
    "*Microsoft.OneConnect*",
    "*Microsoft.People*",
    "*Microsoft.Print3D*",
    "*Microsoft.SkypeApp*",
    "*Microsoft.Wallet*",
    "*Microsoft.Xbox*",
    "*Microsoft.ZuneMusic*",
    "*Microsoft.ZuneVideo*",
    "*Microsoft.YourPhone*",
    "*Microsoft.MixedReality.Portal*",
    "*Xbox*",
    "*YourPhone*",
    "*Phone*",
    "*3DViewer*",
    "*Camera*",
    "*Maps*",
    "*Solitaire*",
    "*CandyCrush*",
    "*Spotify*",
    "*WindowsFeedbackHub*",
    "*GetHelp*",
    "*Todos*",
    "*Office*",
    "*Word*",
    "*Excel*",
    "*BingNews*",
    "*BingSearch*",
    "*GamingApp*",
    "*OutlookForWindows*"
)

foreach ($app in $bloatwareApps) {
    Get-AppxPackage $app -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    Write-Host "Removed: $app" -ForegroundColor Gray
}

Write-Host "Step 2: Removing provisioned packages..." -ForegroundColor Yellow

# Remove provisioned packages
$provisionedApps = @(
    "*BingWeather*",
    "*GetHelp*",
    "*Getstarted*",
    "*Messaging*",
    "*MicrosoftOfficeHub*",
    "*OneConnect*",
    "*People*",
    "*Print3D*",
    "*SkypeApp*",
    "*Wallet*",
    "*ZuneMusic*",
    "*ZuneVideo*",
    "*YourPhone*"
)

foreach ($app in $provisionedApps) {
    Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -like $app} | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Host "Step 3: Disabling unnecessary services..." -ForegroundColor Yellow

# Disable services
$servicesToDisable = @(
    "DiagTrack",
    "dmwappushservice", 
    "WerSvc",
    "PcaSvc",
    "MapsBroker",
    "lfsvc",
    "WSearch",
    "FileSyncHelper",
    "PhoneSvc",
    "QWAVE",
    "SSDPSRV",
    "DusmSvc",
    "WSLService",
    "HvHost",
    "nvagent"
)

foreach ($service in $servicesToDisable) {
    try {
        Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
        Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
        Write-Host "Disabled service: $service" -ForegroundColor Gray
    }
    catch {
        Write-Host "Could not disable service: $service" -ForegroundColor Red
    }
}

# Use sc.exe for services that need it
sc.exe config "WSearch" start= disabled | Out-Null
sc.exe config "DiagTrack" start= disabled | Out-Null
sc.exe config "dmwappushservice" start= disabled | Out-Null

Write-Host "Step 4: Registry optimizations..." -ForegroundColor Yellow

# Disable telemetry
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Force -ErrorAction SilentlyContinue

# Disable background apps
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Force -ErrorAction SilentlyContinue

# Create and set startup delay
New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0 -Force -ErrorAction SilentlyContinue

# Disable Windows Tips
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0 -Force -ErrorAction SilentlyContinue

# Memory management optimizations
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "ClearPageFileAtShutdown" -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Value 1 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "LargeSystemCache" -Value 0 -Force -ErrorAction SilentlyContinue

# NTFS optimization
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "NtfsMftZoneReservation" -Value 2 -Force -ErrorAction SilentlyContinue

# CPU priority optimization
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 26 -Force -ErrorAction SilentlyContinue

# Disable prefetcher and superfetch
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Force -ErrorAction SilentlyContinue

Write-Host "Step 5: Disabling Windows features..." -ForegroundColor Yellow

# Disable Windows features
$featuresToDisable = @(
    "SearchEngine-Client-Package",
    "WorkFolders-Client", 
    "Printing-Foundation-InternetPrinting-Client",
    "Microsoft-Windows-Subsystem-Linux",
    "VirtualMachinePlatform"
)

foreach ($feature in $featuresToDisable) {
    try {
        Disable-WindowsOptionalFeature -Online -FeatureName $feature -NoRestart -ErrorAction SilentlyContinue | Out-Null
        Write-Host "Disabled feature: $feature" -ForegroundColor Gray
    }
    catch {
        Write-Host "Could not disable feature: $feature" -ForegroundColor Red
    }
}

Write-Host "Step 6: Search and indexing optimizations..." -ForegroundColor Yellow

# Disable Windows Search completely
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Search" -Name "SetupCompletedSuccessfully" -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\WSearch" -Name "Start" -Value 4 -Force -ErrorAction SilentlyContinue

# Disable search in taskbar
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Force -ErrorAction SilentlyContinue
New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Force -ErrorAction SilentlyContinue

# Create search policies
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force -ErrorAction SilentlyContinue | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowIndexingEncryptedStoresOrItems" -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowSearchToUseLocation" -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1 -Force -ErrorAction SilentlyContinue

Write-Host "Step 7: Network and power optimizations..." -ForegroundColor Yellow

# Network optimizations
netsh int tcp set global autotuninglevel=normal | Out-Null
netsh int tcp set global rss=enabled | Out-Null

# Power plan optimization
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null

# Disable hibernation
powercfg /hibernate off | Out-Null

# CPU performance optimization
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMAX 100 | Out-Null
powercfg /setacvalueindex scheme_current sub_processor PROCTHROTTLEMIN 100 | Out-Null
powercfg /setactive scheme_current | Out-Null

Write-Host "Step 8: Game mode and Xbox optimizations..." -ForegroundColor Yellow

# Disable Game Mode
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 0 -Force -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0 -Force -ErrorAction SilentlyContinue

# Disable GameDVR
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" -Name "value" -Value 0 -Force -ErrorAction SilentlyContinue

# Stop Xbox services
Stop-Service -Name "XblAuthManager" -Force -ErrorAction SilentlyContinue
Set-Service -Name "XblAuthManager" -StartupType Disabled -ErrorAction SilentlyContinue

Write-Host "Step 9: Disable scheduled tasks..." -ForegroundColor Yellow

# Disable unnecessary scheduled tasks
$tasksToDisable = @(
    "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "Microsoft\Windows\Customer Experience Improvement Program\Consolidator", 
    "Microsoft\Windows\Defrag\ScheduledDefrag"
)

foreach ($task in $tasksToDisable) {
    schtasks /change /tn "$task" /disable 2>$null | Out-Null
    Write-Host "Disabled task: $task" -ForegroundColor Gray
}

Write-Host "Step 10: SSD optimization..." -ForegroundColor Yellow

# Enable TRIM for SSD
fsutil behavior set DisableDeleteNotify 0 | Out-Null

Write-Host "Step 11: Clean temporary files..." -ForegroundColor Yellow

# Clean temp files
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Step 12: Kill resource-heavy processes..." -ForegroundColor Yellow

# Kill processes that consume resources
$processesToKill = @(
    "SearchHost",
    "figma_agent",
    "RiotClientServices",
    "TextInputHost",
    "StartMenuExperienceHost",
    "ShellExperienceHost"
)

foreach ($process in $processesToKill) {
    Stop-Process -Name $process -Force -ErrorAction SilentlyContinue
    Write-Host "Killed process: $process" -ForegroundColor Gray
}

# Force garbage collection
[System.GC]::Collect()
[System.GC]::WaitForPendingFinalizers()
[System.GC]::Collect()

Write-Host "Step 13: Final memory check..." -ForegroundColor Yellow

# Check final memory usage
$totalMem = (Get-CimInstance -ClassName Win32_OperatingSystem).TotalVisibleMemorySize
$freeMem = (Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory
$usedMem = ($totalMem - $freeMem)
$memoryUsagePercent = [math]::Round((($usedMem/$totalMem) * 100),1)

Write-Host ""
Write-Host "=== OPTIMIZATION COMPLETE ===" -ForegroundColor Green
Write-Host "Total RAM: $([math]::Round(($totalMem * 1024)/1GB,1))GB" -ForegroundColor Cyan
Write-Host "Used RAM: $([math]::Round(($usedMem * 1024)/1GB,1))GB ($memoryUsagePercent%)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Key optimizations applied:" -ForegroundColor Yellow
Write-Host "* Removed bloatware apps and provisioned packages" -ForegroundColor Green
Write-Host "* Disabled unnecessary services (DiagTrack, WSearch, etc.)" -ForegroundColor Green
Write-Host "* Disabled Windows features (WSL, Search, etc.)" -ForegroundColor Green
Write-Host "* Optimized memory management and CPU priority" -ForegroundColor Green
Write-Host "* Disabled telemetry and background apps" -ForegroundColor Green
Write-Host "* Configured power plan for performance" -ForegroundColor Green
Write-Host "* Disabled Windows Search and indexing" -ForegroundColor Green
Write-Host "* Optimized network settings" -ForegroundColor Green
Write-Host "* Cleaned temporary files" -ForegroundColor Green
Write-Host ""
Write-Host "IMPORTANT NOTES:" -ForegroundColor Red
Write-Host "* Restart required for all changes to take effect" -ForegroundColor Yellow
Write-Host "* Some Windows UI processes may restart automatically" -ForegroundColor Yellow
Write-Host "* Windows Search functionality will be disabled" -ForegroundColor Yellow
Write-Host "* Re-run this script after major Windows updates" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"