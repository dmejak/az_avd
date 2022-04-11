<#  
.DESCRIPTION  
    Customization script to build a WVD Windows 10ms image
    This script configures the Microsoft recommended configuration for a Win10ms image:
        Article:    Prepare and customize a master VHD image 
                    https://docs.microsoft.com/en-us/azure/virtual-desktop/set-up-customize-master-image 
        Article: Install Office on a master VHD image 
                    https://docs.microsoft.com/en-us/azure/virtual-desktop/install-office-on-wvd-master-image
#>


Write-Host '*** WVD AIB CUSTOMIZER PHASE **************************************************************************************************'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Script: Win10ms_O365.ps1                                                                   ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE ***                                                                                            ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE **************************************************************************************************'

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Stop the custimization when Error occurs ***'
$ErroractionPreference='Stop'
#############################################################################################################################################
# Create devops temp folder to house installation files #

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Create temp folder for software packages. ***'
New-Item -Path 'C:\devopstemp' -ItemType Directory -Force | Out-Null

#############################################################################################################################################
#
#
#
#
#
#
#
#
#
#
#############################################################################################################################################
# Install FSLogix agent #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install FSLogix ***'
# Note: Settings for FSLogix can be configured through GPO's)
Invoke-WebRequest -Uri 'https://aka.ms/fslogix_download' -OutFile 'c:\devopstemp\fslogix.zip'
Expand-Archive -Path 'C:\devopstemp\fslogix.zip' -DestinationPath 'C:\devopstemp\fslogix\'  -Force
Invoke-Expression -Command 'C:\devopstemp\fslogix\x64\Release\FSLogixAppsSetup.exe /install /quiet /norestart'
Start-Sleep -Seconds 10
#############################################################################################################################################
#
#
#
#
#
#
#
#
#
#
#############################################################################################################################################
# Install Chocolatey and install chocolatey apps #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Chocolatey ***'
Invoke-WebRequest -Uri 'https://chocolatey.org/install.ps1' -OutFile ( New-Item -Path "C:\devopstemp\chocolatey\chocolatey.ps1" -Force )
Invoke-Expression -Command 'C:\devopstemp\chocolatey\chocolatey.ps1'
Start-Sleep -Seconds 30

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Run Chocolatey Commands ***'

choco feature enable -n allowGlobalConfirmation

choco install adobereader

Start-Sleep -Seconds 25

choco install googlechrome

Start-Sleep -Seconds 25

choco install javaruntime

Start-Sleep -Seconds 45

choco install 7zip.install

Start-Sleep -Seconds 45

choco install pdf24

choco feature disable -n allowGlobalConfirmation
#############################################################################################################################################
#
#
#
#
#
#
#
#
#
#
#############################################################################################################################################
# Mount app repo fileshare #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** Step 1 *** Mounting AFS ***'
Import-Module -Name SmbShare -Force -Scope Local
New-SmbMapping -LocalPath Z: -RemotePath "\\miusazrusw2apprepo001.file.core.windows.net\afs-usw2apprepo001" -UserName "Azure\miusazrusw2apprepo001" -Password "7WM0UZYoDWw1AKYT3szGCz77Ja9IyvvUJK88QfQznT09aQFT4q+antp8eGjYugq5kupwH32QAfSsUYZVFhbQGw=="
Write-Host '*** Z Mounted ***'
Start-Sleep 5
#############################################################################################################################################
#
#
#
#
#
#
#
#
#
#
#############################################################################################################################################
# Install Opera #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Opera 3 step ***'
Copy-Item -Path 'Z:\20H2-USW2-WVD-GEN-001\Opera\Opera_Install_Files' -Destination 'C:\devopstemp\opera' -Recurse
Invoke-Expression -Command "C:\devopstemp\opera\1installRegTerm.exe /s"
Start-Sleep 5
Invoke-Expression -Command "C:\devopstemp\opera\2installOperaPrintCtrl.exe /s"
Start-Sleep 5
Invoke-Expression -Command "C:\devopstemp\opera\3installJInitCheck.exe /s"
Start-Sleep 5
#############################################################################################################################################
#
#
#
#
#
#
#
#
#
#
#############################################################################################################################################
# Copy Oracle Hospitality folders to program files #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** COPY *** Oracle Hospitality - MTU5 and US801 ***'
Copy-Item -Path 'Z:\20H2-USW2-WVD-GEN-001\EMC\Oracle Hospitality - MTU5' -Destination 'C:\Program Files' -Recurse
Copy-Item -Path 'Z:\20H2-USW2-WVD-GEN-001\EMC\Oracle Hospitality - US801' -Destination 'C:\Program Files' -Recurse
#############################################################################################################################################
#
#
#
#
#
#
#
#
#
#
#############################################################################################################################################
# Copy Public Desktop folder and c:\temp folder from app repo (20h2) #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** COPY *** Public Desktop - Links and icons ***'
Copy-Item -Path 'Z:\20H2-USW2-WVD-GEN-001\desktop_shortcuts\*' -Destination 'C:\Users\Public\Desktop' -Recurse
Copy-Item -Path 'Z:\20H2-USW2-WVD-GEN-001\Temp' -Destination 'C:\' -Recurse
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** COPY *** Folders Copied! ***'
#############################################################################################################################################
#
#
#
#
#
#
#
#
#
#
#############################################################################################################################################
# Windows customization and optimization #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** START OS CONFIG *** Update the recommended OS configuration ***'
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Automatic Updates ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' -Name 'NoAutoUpdate' -Value '1' -PropertyType DWORD -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Specify Start layout for Windows 10 PCs (optional) ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer' -Name 'SpecialRoamingOverrideAllowed' -Value '1' -PropertyType DWORD -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Set up time zone redirection ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services' -Name 'fEnableTimeZoneRedirection' -Value '1' -PropertyType DWORD -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** Disable Storage Sense ***'
# reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\StorageSense\Parameters\StoragePolicy" /v 01 /t REG_DWORD /d 0 /f
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\StorageSense' -Name 'AllowStorageSenseGlobal' -Value '0' -PropertyType DWORD -Force | Out-Null

# Note: Remove if not required!
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** SET OS REGKEY *** For feedback hub collection of telemetry data on Windows 10 Enterprise multi-session ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' -Name 'AllowTelemetry' -Value '3' -PropertyType DWORD -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG OFFICE Regkeys *** Set Office Update Notifiations behavior ***'
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate' -Name 'hideupdatenotifications' -Value '1' -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate' -Name 'hideenabledisableupdates' -Value '1' -PropertyType DWORD -Force | Out-Null
#############################################################################################################################################
#
#
#
#
#
#
#
#
#
#############################################################################################################################################
# WVD and teams additional software and agents #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install C++ Redist for RTCSvc (Teams Optimized) ***'
Invoke-WebRequest -Uri 'https://aka.ms/vs/16/release/vc_redist.x64.exe' -OutFile 'c:\devopstemp\vc_redist.x64.exe'
Invoke-Expression -Command 'C:\devopstemp\vc_redist.x64.exe /install /quiet /norestart'
Start-Sleep -Seconds 15

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install RTCWebsocket to optimize Teams for WVD ***'
New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Force | Out-Null
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Teams' -Name 'IsWVDEnvironment' -Value '1' -PropertyType DWORD -Force | Out-Null
Invoke-WebRequest -Uri 'https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RE4vkL6' -OutFile 'c:\devopstemp\MsRdcWebRTCSvc_HostSetup_0.11.0_x64.msi' 
Invoke-Expression -Command 'msiexec /i c:\devopstemp\MsRdcWebRTCSvc_HostSetup_0.11.0_x64.msi /quiet /l*v C:\devopstemp\MsRdcWebRTCSvc_HostSetup.log ALLUSER=1'
Start-Sleep -Seconds 15
##############################################################################################################################################
#
#
#
#
#
#
#
#
# Final Cleanup #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Deleting temp folder. ***'
Get-ChildItem -Path 'C:\devopstemp' -Recurse | Remove-Item -Recurse -Force
Remove-Item -Path 'C:\devopstemp' -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************* END *************************'
#############################################################################################################################################




