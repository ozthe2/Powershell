<#
Purpose: Installs and patches Adobe Reader DC
Created by: OH
Date: 2018-01-03
Version: 1.0.0
#>


$WorkingDir = Get-Location

#Stop processess
"AdobeARM","AcroRd32" | % {Stop-Process -name $_ -Force -ea SilentlyContinue}

#Install Adobe Reader DC
Start-Process -FilePath 'C:\Windows\System32\msiexec.exe' -ArgumentList "/i $WorkingDir\acroread.msi TRANSFORMS=acroread.mst /q /norestart" -NoNewWindow -Wait

#Install msp Patch
Start-Process -FilePath 'C:\Windows\System32\msiexec.exe' -ArgumentList "/update AcroRdrDCUpd1901020064.msp /q /norestart" -NoNewWindow -Wait
