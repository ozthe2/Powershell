Function Invoke-PreInstallation {
    # Anything you do here will occur **before** the installation...
    # Perhaps copy some files, register some DLL's or anything else you can think of!
}

function Invoke-PostInstallation {
    # Anything you do here will occur **after** the installation...
    # Perhaps copy some files, register some DLL's or anything else you can think of!
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
                $true {"Install a 32-bit application here"}
                $false {"Install a 64-bit application here"}
                'Unknown' {"Office not detected - do what you want here"}     
            }
        }
        else {
            # Installs a 64bt or 32bit application depending on the OS Architecture.
            # $True = The OS Architecture is 64-bit - Use this part to install the 64-bit application.
            # default = The OS is 32-Bit - Use this part to install the 32-bit application.

            switch ($obj.OSIs64Bit) {
                $True {start-process -FilePath "$workingdir\OneDriveSetup.exe" -ArgumentList "/allusers /silent" -NoNewWindow -Wait}
                default {start-process -FilePath "$workingdir\OneDriveSetup.exe" -ArgumentList "/allusers /silent" -NoNewWindow -Wait}
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

#Script entry point
Invoke-ApplicationInstall
