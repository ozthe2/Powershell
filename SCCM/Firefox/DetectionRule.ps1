$VersionNumber = '69.0'
$Executable = "firefox.exe"
$Path = "$env:ProgramFiles\mozilla firefox"

$RegistryKey = 'HKLM:\SOFTWARE\Mozilla\Mozilla Firefox'
$Value = 'CurrentVersion'
$Data = '69.0 (x64 en-US)'

If ((Get-item (Join-Path -Path $Path -ChildPath $Executable) -ErrorAction SilentlyContinue).VersionInfo.ProductVersion -eq $VersionNumber -and (Get-ItemProperty -Path $RegistryKey | Select-Object $Value -ExpandProperty $Value -ErrorAction SilentlyContinue) -eq $data) {
    Write-Host "Detected!"
}
