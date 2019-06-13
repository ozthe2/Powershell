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
https://fearthepanda.com
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
        $WorkingDir = $MyInvocation.PSScriptRoot

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


Function Install-Mimecast {
<#
.SYNOPSIS
    Installs the Mimecast for Outlook plugin
.DESCRIPTION
    The Mimecast for Outlook plugin requires that Outlook be closed before installation.  It also requires that the 32 bit version of the plugin be installed
    if the installed Microsoft Office version is 32 bit.  Likewise, if the installed Microsoft Office version is 64 bit, then the 64bit version of the Mimecast plugin needs to be installed.
    This PowerShell script takes care of all of this.
.PARAMETER 64bit_msi_Name
    The name of the 64 bit msi including the .msi extension.  
.EXAMPLE
    PS C:\> Install-Mimecast -64bit_msi_Name "x64_Mimecast.msi"
.PARAMETER 32bit_msi_Name
    The name of the 32 bit msi including the .msi extension.  
.EXAMPLE
    PS C:\> Install-Mimecast -32bit_msi_Name "x32_Mimecast.msi"
.NOTES
SCCM usage: Place this script and both msi's (32 and 64 bit) in the same source folder on your sccm server and create a new Application which deploys this script.
Example:for Installation Program use the following:  powershell.exe -executionpolicy bypass -file ".\install-mimecast.ps1"
Created by: OH
Date: 12-Oct-2018

#13-June-2019 - Version 1.1 - Added checking for O365 ProPlus installation
#>
[CmdletBinding()]

param (
    [parameter (Mandatory=$false)]
    [string]
    $64bit_msi_Name = "Mimecast for outlook 7.7.0.362 (64 Bit).msi",

    [parameter (Mandatory=$false)]
    [string]
    $32bit_msi_Name = "Mimecast for outlook 7.7.0.362 (32 Bit).msi"
)
    
    Begin {
        $WorkingDir = $MyInvocation.PSScriptRoot

        Push-Location
        
        $OfficePath = 'HKLM:\Software\Microsoft\Office'
        $OfficeVersions = @('14.0','15.0','16.0')
           
        foreach ($Version in $OfficeVersions) {
            try {
                Set-Location "$OfficePath\$Version\Outlook" -ea stop -ev x
                $LocationSet = $true
                break
            } catch {
                $LocationSet = $false
            }
        }

        # Test for O365 ProPlus...
        if (!($LocationSet)) {
            $OfficePath = 'HKLM:\Software\Microsoft\Office\ClickToRun\Scenario\INSTALL'
            try {
                Set-Location $OfficePath -ea stop -ev x
                $LocationSet = $true
            } catch {
                $LocationSet = $false
            }
        }
    }

    process {
        #Check to see if outlook has started, if so, close it..Mimecast will not install if outlook is open.
        Get-Process 'OUTLOOK' -ea SilentlyContinue | Stop-Process -Force

        if ($locationSet) {
            #Check for bitness and install correct version
            try {
                switch (Get-ItemPropertyValue -Name "Bitness" -ea stop) {
                    "x86" { Start-Process 'C:\Windows\System32\msiexec.exe' " /i ""$WorkingDir\$32bit_msi_Name"" /qn" -NoNewWindow -Wait }
                    "x64" { Start-Process 'C:\Windows\System32\msiexec.exe' " /i ""$WorkingDir\$64bit_msi_Name"" /qn" -NoNewWindow -Wait }
                }
            } catch {
                switch (Get-ItemPropertyValue -Name "Platform") {
                    "x86" { Start-Process 'C:\Windows\System32\msiexec.exe' " /i ""$WorkingDir\$32bit_msi_Name"" /qn" -NoNewWindow -Wait }
                    "x64" { Start-Process 'C:\Windows\System32\msiexec.exe' " /i ""$WorkingDir\$64bit_msi_Name"" /qn" -NoNewWindow -Wait }
                }
            }
        }
    }

    end {
        Pop-Location        
    }
}

#Script Entry point

#Close outlook if its open
Get-Process 'OUTLOOK' -ea SilentlyContinue | Stop-Process -Force

#Uninstall previous versions of mimecast
Invoke-ApplicationRemoval -UninstallSearchFilter "mimecast"

#Install deployed version of Mimexast
Install-Mimecast
