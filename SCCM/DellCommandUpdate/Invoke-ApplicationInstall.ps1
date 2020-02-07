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

Function Invoke-PreInstallation {   
    # Anything you do here will occur **before** the installation...
    # Perhaps copy some files, register some DLL's or anything else you can think of!
}

function Invoke-PostInstallation {
    # Remove desktop shortcut icon as not required.
    remove-item -Path "C:\Users\Public\Desktop\Zoom.lnk" -Filter "*.lnk" -ErrorAction SilentlyContinue
}

Function Invoke-ApplicationInstall {

    # Installs applications depending on office bitness or os bitness
    # To install using Office bitness, use the switch -InstallBasedOnOfficeBitness
    # To install based on OS architecture (32-bit or 64-bit) do not use the switch

    [CmdletBinding()]

    Param (
        [Switch]
        $InstallBasedOnOfficeBitness
    )

    Begin {
        $WorkingDir = Get-Location
        $LoggedInUser = (Get-CimInstance -ClassName CIM_ComputerSystem).username | Split-Path -Leaf
        $OSArchitecture = (Get-CimInstance -ClassName CIM_OperatingSystem).OSArchitecture
        $OfficePaths = @('HKLM:\Software\Microsoft\Office','HKLM:\Software\WOW6432Node\Microsoft\Office')
        $OfficeVersions = @('14.0', '15.0', '16.0')

        Push-Location

        foreach ($Path in $OfficePaths) {
            foreach ($Version in $OfficeVersions) {
                try {
                    Set-Location "$Path\$Version\Outlook" -ea stop -ev x
                    $Bitness = Get-ItemPropertyValue -Name "Bitness" -ea stop -ev x
                    switch ($bitness) {
                        'x86' {$Is32Bit = $True}
                        'x64' {$Is32Bit = $false}                
                    }
                    break
                } catch {
                    $Is32Bit = 'Unknown'
                }
            }
            if ($Is32Bit -eq $true -or $Is32Bit -eq $false) {break}
        }

        $Obj = [pscustomobject]@{
            CurrentUser   = $LoggedInUser
            OfficeIs32Bit = $Is32Bit
            OSis64Bit     = if ($OSArchitecture -eq '64-Bit') {$True} else {$false}                
        }

        Pop-Location
    }

    Process { 
        # --- PRE-INSTALL SECTION ---       
        
        Invoke-PreInstallation
        
        # --- END PRE-INSTALL ---

        if ($InstallBasedOnOfficeBitness) {
            # Install the application depending on if Microsoft Office is 64bit or 32bit or not installed
            # $True = Office is 32bit - Use this part to install 32bit applications
            # False = Office is 64bit - Use this part to install 64bit applications
            # Unknown = Office may not be installed.

            switch ($Obj.OfficeIs32Bit) {
                $true {""}
                $false {"" }
                'Unknown' {"Office not detected - do what you want here"}     
            }
        }
        else {
            # Installs a 64bt or 32bit application depending on the OS Architecture.
            # $True = The OS Architecture is 64-bit - Use this part to install the 64-bit application.
            # default = The OS is 32-Bit - Use this part to install the 32-bit application.

            switch ($obj.OSIs64Bit) {
                $True {start-process -FilePath "$workingdir\Dell-Command-Update_0NJ7C_WIN_3.1.0_A00.EXE" -ArgumentList "/s" -NoNewWindow -Wait}
                default {start-process -FilePath "$workingdir\Dell-Command-Update_0NJ7C_WIN_3.1.0_A00.EXE" -ArgumentList "/s" -NoNewWindow -Wait}
            }
        }

        # --- POST-INSTALL SECTION ---        
        
        Invoke-PostInstallation

        # --- END POST-INSTALL SECTION

    }

    End {
        # Write what the discovered object values are to a log.
        # This may help in troubleshooting.  
        # Feel free to expand this section to include anything else that you want logged.     
        "Logged In User: $($Obj.CurrentUser)" | out-file -FilePath ".\Invoke-ApplicationInstall.log" -ErrorAction SilentlyContinue
        "Office Version is 32Bit: $($Obj.OfficeIs32Bit)" | out-file -FilePath ".\Invoke-ApplicationInstall.log" -Append -ErrorAction SilentlyContinue
        "Operating System is 64Bit: $($Obj.OSis64Bit)" | out-file -FilePath ".\Invoke-ApplicationInstall.log" -Append -ErrorAction SilentlyContinue
    }
}

# Script entry point
Invoke-ApplicationRemoval -UninstallSearchFilter "dell command | update"
Invoke-ApplicationInstall
