function Install-RSATCapabilites {
<#
.Synopsis
Installs RSAT Capabilities for Windows 10 October 2018 Update or higher.
.DESCRIPTION
Installs a core set of RSAT capabilities:
- DNS Server Tools
- Group Policy Management Tools
- Active Directory Domain Services and Lightweight Directory Services Tools
- DHCP Server Tools
- File Services Tools
- IP Address Management (IPAM) Client
- Volume Activation Tools
- Active Directory Certificate Services Tools
- Bitlocker Administration Utilties

To add or remove capabilities, simply edit the $Components array in the BEGIN section.
See https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/features-on-demand-non-language-fod#remote-server-administration-tools-rsat

.EXAMPLE
Install-RSATCapabilities

Installs the RSAT capabilities listed in the $Components array
.NOTES
Version: 1.0.0
Date: 20191016
Created By: OzThe2
.LINK
https://fearthepanda.com
.LINK
https://leanpub.com/configmgr-DeployUsingPS
.LINK
https://github.com/ozthe2
#>
    
    [CmdletBinding()]

    param()

    BEGIN {        

        $Components = @('Rsat.Dns.Tools~~~~0.0.1.0','Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0','Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0',
                        'Rsat.DHCP.Tools~~~~0.0.1.0','Rsat.FileServices.Tools~~~~0.0.1.0','Rsat.IPAM.Client.Tools~~~~0.0.1.0',
                        'Rsat.VolumeActivation.Tools~~~~0.0.1.0','Rsat.CertificateServices.Tools~~~~0.0.1.0','Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0')

        $val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | select -ExpandProperty UseWUServer -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0 -ErrorAction SilentlyContinue
        Restart-Service wuauserv -ErrorAction SilentlyContinue
    }

    PROCESS {
        foreach ($Component in $Components) {
            $InstallState = (Get-WindowsCapability -Name $Component -Online -ErrorAction SilentlyContinue).state
            if ($InstallState -eq "NotPresent") {
                Write-Verbose "Adding: $Component..."
                Add-WindowsCapability -Online -Name $Component -ErrorAction SilentlyContinue
            } else {
                write-verbose "$Component already present."
            }
        }
    }

    END {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $val -ErrorAction SilentlyContinue
        Restart-Service wuauserv -ErrorAction SilentlyContinue
    }
}

function Uninstall-RSATCapabilites {
<#
.Synopsis
Uninstalls RSAT Capabilities for Windows 10 October 2018 Update or higher.
.DESCRIPTION
Uninstalls a core set of RSAT capabilities:
- DNS Server Tools
- Group Policy Management Tools
- Active Directory Domain Services and Lightweight Directory Services Tools
- DHCP Server Tools
- File Services Tools
- IP Address Management (IPAM) Client
- Volume Activation Tools
- Active Directory Certificate Services Tools
- Bitlocker Administration Utilties

To add or remove capabilities, simply edit the $Components array in the BEGIN section.
See https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/features-on-demand-non-language-fod#remote-server-administration-tools-rsat

.EXAMPLE
Uninstall-RSATCapabilities

Uninstalls the RSAT capabilities listed in the $Components array
.NOTES
Version: 1.0.0
Date: 20191016
Created By: OzThe2
.LINK
https://fearthepanda.com
.LINK
https://leanpub.com/configmgr-DeployUsingPS
.LINK
https://github.com/ozthe2
#>
    
    [CmdletBinding()]

    param()

    BEGIN {        

        $Components = @('Rsat.Dns.Tools~~~~0.0.1.0','Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0','Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0',
                        'Rsat.DHCP.Tools~~~~0.0.1.0','Rsat.FileServices.Tools~~~~0.0.1.0','Rsat.IPAM.Client.Tools~~~~0.0.1.0',
                        'Rsat.VolumeActivation.Tools~~~~0.0.1.0','Rsat.CertificateServices.Tools~~~~0.0.1.0','Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0')

        $val = Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" | select -ExpandProperty UseWUServer -ErrorAction SilentlyContinue
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 0 -ErrorAction SilentlyContinue
        Restart-Service wuauserv -ErrorAction SilentlyContinue
    }

    PROCESS {
        foreach ($Component in $Components) {
            $InstallState = (Get-WindowsCapability -Name $Component -Online -ErrorAction SilentlyContinue).state
            if ($InstallState -eq "Installed") {
                Write-Verbose "Uninstalling: $Component..."
                Remove-WindowsCapability -Online -Name $Component -ErrorAction SilentlyContinue
            } else {
                write-verbose "Cannot uninstall $Component as it is not present on this system."
            }
        }
    }

    END {
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value $val -ErrorAction SilentlyContinue
        Restart-Service wuauserv -ErrorAction SilentlyContinue
    }
}
