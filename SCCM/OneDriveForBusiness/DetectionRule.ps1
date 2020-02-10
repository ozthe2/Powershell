$VersionNumber = '19.222.1110.0006'
$Executable = 'OneDrive.exe'
$ProgramPath = "${ENV:ProgramFiles(x86)}\Microsoft OneDrive"


If ((Get-item (Join-Path -Path $ProgramPath -ChildPath $Executable) -ErrorAction SilentlyContinue).VersionInfo.ProductVersion -eq $VersionNumber)  {
    Write-Host "Detected!"
}
