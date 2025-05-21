# Optimize Windows 11 for Server Performance

Here is a PowerShell script that disables or optimizes various background services and telemetry settings in Windows 11 for better server performance. The script includes detailed documentation in English, so you understand what each section does and can adjust it as needed.

```powershell
<#
.SYNOPSIS
Optimizes Windows 11 by disabling unnecessary background services and telemetry features for better server performance.

.DESCRIPTION
This script disables Windows Search, Telemetry, Superfetch, OneDrive, Xbox services, and several other background components that are not needed on a server.

.NOTES
Run this script as Administrator.
Test in a VM or non-critical environment before deploying in production.
#>

# Ensure script is running as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Please run this script as Administrator."
    Exit
}

Write-Output "`n=== Starting Windows 11 Server Optimization Script ===`n"

# ------------------------------
# 1. Disable Windows Search (Indexing)
# ------------------------------
Write-Output "Disabling Windows Search service..."
Stop-Service 'WSearch' -Force -ErrorAction SilentlyContinue
Set-Service 'WSearch' -StartupType Disabled

# ------------------------------
# 2. Disable Telemetry Services
# ------------------------------
Write-Output "Disabling telemetry services..."
$telemetryServices = @(
    "DiagTrack",                   # Connected User Experiences and Telemetry
    "dmwappushservice"            # Diagnostic Service Host
)
foreach ($svc in $telemetryServices) {
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service $svc -StartupType Disabled
}

# ------------------------------
# 3. Disable Superfetch (SysMain)
# ------------------------------
Write-Output "Disabling SysMain (Superfetch)..."
Stop-Service 'SysMain' -Force -ErrorAction SilentlyContinue
Set-Service 'SysMain' -StartupType Disabled

# ------------------------------
# 4. Optional: Disable Windows Error Reporting
# ------------------------------
Write-Output "Disabling Windows Error Reporting..."
Set-Service 'WerSvc' -StartupType Disabled

# ------------------------------
# 5. Disable Xbox-related services
# ------------------------------
Write-Output "Removing Xbox apps..."
Get-AppxPackage *xbox* | Remove-AppxPackage -ErrorAction SilentlyContinue

# ------------------------------
# 6. Disable Cortana
# ------------------------------
Write-Output "Removing Cortana..."
Get-AppxPackage *cortana* | Remove-AppxPackage -ErrorAction SilentlyContinue

# ------------------------------
# 7. Remove OneDrive (optional)
# ------------------------------
Write-Output "Uninstalling OneDrive..."
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
$onedrive = "$env:SystemRoot\System32\OneDriveSetup.exe"
If (Test-Path $onedrive) {
    Start-Process $onedrive "/uninstall" -NoNewWindow -Wait
}

# ------------------------------
# 8. Disable Background Apps
# ------------------------------
Write-Output "Disabling background apps for all users..."
New-ItemProperty -Path "HKLM\SOFTWARE\Policies\Microsoft\Windows\AppPrivacy" -Name "LetAppsRunInBackground" -PropertyType DWord -Value 2 -Force | Out-Null

# ------------------------------
# 9. Disable Some Optional Services
# ------------------------------
$optionalServices = @(
    "Fax",
    "Spooler",                    # Print Spooler
    "Bluetooth Support Service",
    "WiaRpc",                     # Windows Image Acquisition
    "TabletInputService"          # Touch Keyboard & Handwriting
)
foreach ($svc in $optionalServices) {
    Write-Output "Disabling optional service: $svc"
    Stop-Service $svc -Force -ErrorAction SilentlyContinue
    Set-Service $svc -StartupType Disabled
}

# ------------------------------
# 10. Disable Windows Update (optional - not recommended for security reasons)
# ------------------------------
<#
Write-Output "Disabling Windows Update service..."
Stop-Service 'wuauserv' -Force -ErrorAction SilentlyContinue
Set-Service 'wuauserv' -StartupType Disabled
#>

# ------------------------------
# 11. Disable Remote Registry (optional)
# ------------------------------
Write-Output "Disabling Remote Registry..."
Stop-Service 'RemoteRegistry' -Force -ErrorAction SilentlyContinue
Set-Service 'RemoteRegistry' -StartupType Disabled

# ------------------------------
# DONE
# ------------------------------
Write-Output "`n=== Optimization complete. Restart recommended. ===`n"

```
