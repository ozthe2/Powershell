#Requires -Version 3.0
Function Invoke-ApplicationRemoval {
<#
.SYNOPSIS
    Uninstalls an application
.DESCRIPTION
    Uninstalls one or more applications by searching the registry based on the 'DisplayName' that matches your filter.
    It is recommended that you run this function with the -WhatIf parameter first to ensure that it will uninstall the expected application(s)
    By default, a 'like' search is performed; meaning if your filter is 'Adobe Acrobat', it would find Adobe Acrobat Reader DC' AND 'Adobe Acrobat Reader Pro' and attempt removal.
    If this is not desired, you can use the switch -Exact and change your filter to 'Adobe Acrobat Reader DC' and then only that exact application will be removed. 
.PARAMETER UninstallSearchFilter
    The application name that you are looking to uninstall.  This can be part of a name and a 'like' search will be performed by default.
    The search is made against the applications 'DisplayName' found in the registry: 
    HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall
    or
    HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall
.EXAMPLE    
PS C:\Scripts> 'firefox' | Invoke-ApplicationRemoval -WhatIf
What if: Performing the operation "Uninstall" on target "Mozilla Firefox 63.0.3 (x64 en-GB)"
What if: Performing the operation "Uninstall" on target "Mozilla Firefox 63.0.3 (x86 en-GB)"
.EXAMPLE
PS C:\Scripts> 'reader dc' | Invoke-ApplicationRemoval -WhatIf
What if: Performing the operation "Uninstall" on target "Adobe Acrobat Reader DC"
.PARAMETER Exact
    Does not perform a 'like' search. Eg if your filter is 'Java', only applications with a display name exactly of 'Java' will be removed.
    Performs a removal of any application whose registry DisplayName is an exact match for your filter.
.EXAMPLE
Invoke-ApplicationRemoval "Adobe Acrobat Reader DC" -Exact
    If installed, Adobe Acrobat Reader DC will be uninstalled.  If Adobe Acrobat Reader Pro is also installed, this will remain.
.NOTES
Created by OH
https://www.fearthepanda.com
Version: 1.0.1
#>
[CmdletBinding(SupportsShouldProcess=$True)]

param (
    [parameter (Mandatory=$true,
    ValueFromPipeline = $true)]     
    [string[]]
    $UninstallSearchFilter,

    [Switch]
    $Exact
)
    
    Begin {
        #$WorkingDir = $MyInvocation.PSScriptRoot        
        $WorkingDir = Get-Location

        $RegUninstallPaths = @(
            'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
            'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall') 
    }

    process {        
        foreach ($Filter in $UninstallSearchFilter) {
            foreach ($Path in $RegUninstallPaths) {
                if (Test-Path $Path) {
                    if ($Exact) {                   
                        $Results = Get-ChildItem $Path | Where {$_.GetValue('DisplayName') -eq $Filter}
                    } else {
                        $Results = Get-ChildItem $Path | Where {$_.GetValue('DisplayName') -Like "*$Filter*"}
                    }
                    Foreach ($Result in $Results) {                        
                        if ($PSCmdlet.ShouldProcess($Result.getvalue('displayname'),"Uninstall")) {
                            Start-Process 'C:\Windows\System32\msiexec.exe' "/x $($Result.PSChildName) /qn" -Wait -NoNewWindow                            
                        }
                    }
                }
            }
        }
    }

    end {}
}

#*** SCRIPT ENTRY POINT **

#Java Removal and installation of JRE x86 and x64
#------------------------------------------------
#ConfigMgr Install line: powershell.exe -executionpolicy bypass -file .\JavaVersionManagement.ps1

$WorkingDir = Get-Location

#Stop Java Processes
#write-host "Stopping processses"
Get-WmiObject Win32_Process | Where {$_.ExecutablePath -like '*Program Files\Java\*'} | Select @{n='Name';e={$_.Name.Split('.')[0]}} | Stop-Process -Force

#Remove all installed Java instances.
#write-host "Removing Java"
Invoke-ApplicationRemoval -UninstallSearchFilter "java"

#Remove directory
#write-host "removing java directory"
Remove-Item "$env:ProgramFiles\Java\" -Force -Recurse -ErrorAction SilentlyContinue
Remove-Item "${env:ProgramFiles(x86)}\Java\" -Force -Recurse -ErrorAction SilentlyContinue

#Install Java
#Write-host "Installing Java"
Start-Process 'C:\Windows\System32\msiexec.exe' "/i $WorkingDir\jre1.8.0_191.msi /qn JAVAUPDATE=0 AUTOUPDATECHECK=0 IEXPLORER=1 REBOOT=Suppress" -NoNewWindow -Wait
Start-Process 'C:\Windows\System32\msiexec.exe' "/i $WorkingDir\jre1.8.0_19164.msi /qn JAVAUPDATE=0 AUTOUPDATECHECK=0 IEXPLORER=1 REBOOT=Suppress" -NoNewWindow -Wait
#write-host "Done!"
