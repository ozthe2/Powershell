$VersionNumber = '4,6,17409,0120'
$Executable = "zoom.exe"
$Path = "${env:ProgramFiles(x86)}\Zoom\Bin"

If ((Get-item (Join-Path -Path $Path -ChildPath $Executable) -ErrorAction SilentlyContinue).VersionInfo.ProductVersion -eq $VersionNumber){
    Write-Host "Detected!"
}
