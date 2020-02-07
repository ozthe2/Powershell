$VersionNumber = '3.1.0.64'
$Executable = "dcu-cli.exe"
$Path = "${env:ProgramFiles(x86)}\dell\commandupdate"

If ((Get-item (Join-Path -Path $Path -ChildPath $Executable) -ErrorAction SilentlyContinue).VersionInfo.ProductVersion -eq $VersionNumber){
    Write-Host "Detected!"
}
