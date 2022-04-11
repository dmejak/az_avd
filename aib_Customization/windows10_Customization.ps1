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
#############################################################################################################################################
# Install Chocolatey and install chocolatey apps #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Install Chocolatey ***'
Invoke-WebRequest -Uri 'https://chocolatey.org/install.ps1' -OutFile ( New-Item -Path "C:\devopstemp\chocolatey\chocolatey.ps1" -Force )
Invoke-Expression -Command 'C:\devopstemp\chocolatey\chocolatey.ps1'
Start-Sleep -Seconds 10

Write-Host '*** WVD AIB CUSTOMIZER PHASE *** INSTALL *** Run Chocolatey Commands ***'

choco feature enable -n allowGlobalConfirmation

choco install adobereader

Start-Sleep -Seconds 10

choco install googlechrome

Start-Sleep -Seconds 10

choco install 7zip.install

choco feature disable -n allowGlobalConfirmation
#############################################################################################################################################
# Final Cleanup #
Write-Host '*** WVD AIB CUSTOMIZER PHASE *** CONFIG *** Deleting temp folder. ***'
Get-ChildItem -Path 'C:\devopstemp' -Recurse | Remove-Item -Recurse -Force
Remove-Item -Path 'C:\devopstemp' -Force | Out-Null

Write-Host '*** WVD AIB CUSTOMIZER PHASE ********************* END *************************'
#############################################################################################################################################




