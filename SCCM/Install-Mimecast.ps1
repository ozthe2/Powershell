#Requires -Version 3.0
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
#>
[CmdletBinding()]

param (
    [parameter (Mandatory=$false)]
    [string]
    $64bit_msi_Name = "Mimecast for Outlook 7.6.0.26320 (64 bit).msi",

    [parameter (Mandatory=$false)]
    [string]
    $32bit_msi_Name = "Mimecast for Outlook 7.6.0.26320 (32 bit).msi"
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
    }

    process {  
        if ($locationSet) {
            #Check to see if outlook has started, if so, close it..Mimecast will not install if outlook is open.
            Get-Process 'OUTLOOK' -ea SilentlyContinue | Stop-Process -Force
            #Check for bitness and install correct version
            switch (Get-ItemPropertyValue -Name "Bitness") {
                "x86" { Start-Process 'C:\Windows\System32\msiexec.exe' " /i ""$WorkingDir\$32bit_msi_Name"" /qn" -NoNewWindow -Wait }
                "x64" { Start-Process 'C:\Windows\System32\msiexec.exe' " /i ""$WorkingDir\$64bit_msi_Name"" /qn" -NoNewWindow -Wait }
            }
        }
    }

    end {
        Pop-Location        
    }
}

#Script Entry point
Install-Mimecast
