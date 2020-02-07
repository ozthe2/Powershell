$MimecastVersion = '7.8.0.125'

$OfficePaths = @('HKLM:\Software\Microsoft\Office','HKLM:\Software\WOW6432Node\Microsoft\Office')
$OfficeVersions = @('14.0', '15.0', '16.0')
$LocationSet = $false      

foreach ($Path in $OfficePaths) {
    foreach ($Version in $OfficeVersions) {
        try {
            Set-Location "$Path\$Version\Outlook" -ea stop -ev x
            $Bitness = Get-ItemPropertyValue -Name "Bitness" -ea stop -ev x
            switch ($bitness) {
                'x86' {$LocationSet = $True}
                'x64' {$LocationSet = $True}                
            }
            break
        } catch {
            $LocationSet = $false
        }
    }
    if ($LocationSet -eq $true) {break}
}

if ($locationSet) {
    # Check for bitness and install correct version           
    switch (Get-ItemPropertyValue -Name "Bitness" -ea SilentlyContinue) {
        "x86" { if ((get-item "${env:ProgramFiles(x86)}\Mimecast\Mimecast Outlook Add-In\en-GB\Mimecast.Services.Outlook.Assets.resources.dll" -ErrorAction SilentlyContinue).VersionInfo.fileversion -eq $MimecastVersion) { Write-host "Installed!"} }
        "x64" { if ((get-item "$ENV:ProgramFiles\Mimecast\Mimecast Outlook Add-In\en-GB\Mimecast.Services.Outlook.Assets.resources.dll" -ErrorAction SilentlyContinue).VersionInfo.fileversion -eq $MimecastVersion) { Write-host "Installed!"} }
    }           
}
