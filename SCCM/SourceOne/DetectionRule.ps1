$RegistryKey32 = 'HKLM:\SOFTWARE\WOW6432Node\EMC\SourceOne\Versions'
$RegistryKey64 = 'HKLM:\SOFTWARE\EMC\SourceOne\Versions' 
$Value32 = 'OfflineAccess'
$Value64 = 'OfflineAccessx64'
$Data = '7.27.7017'

$OfficePaths = @('HKLM:\Software\Microsoft\Office','HKLM:\Software\WOW6432Node\Microsoft\Office')
$OfficeVersions = @('14.0', '15.0', '16.0')

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

if ($Is32Bit) {
    if ((Get-ItemProperty -Path $RegistryKey32 | Select-Object $Value -ExpandProperty $Value32 -ErrorAction SilentlyContinue) -eq $data) {
        Write-Host "Detected!"
    }
} else {
    if ((Get-ItemProperty -Path $RegistryKey64 | Select-Object $Value -ExpandProperty $Value64 -ErrorAction SilentlyContinue) -eq $data) {
        Write-Host "Detected!"
    }
}
