$Components = @('Rsat.Dns.Tools~~~~0.0.1.0','Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0','Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0', 'Rsat.DHCP.Tools~~~~0.0.1.0','Rsat.FileServices.Tools~~~~0.0.1.0','Rsat.IPAM.Client.Tools~~~~0.0.1.0', 'Rsat.VolumeActivation.Tools~~~~0.0.1.0','Rsat.CertificateServices.Tools~~~~0.0.1.0','Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0')
 foreach ($Component in $Components) {
    $InstallState = (Get-WindowsCapability -Name $Component -Online -ErrorAction SilentlyContinue).state
        if ($InstallState -eq "Installed") {
            $Result = $true
        } else {
            $result = $false
            break
        }
}

if ($result) {
    write-host "Installed!"
}
