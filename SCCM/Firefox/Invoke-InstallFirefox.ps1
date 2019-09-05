<#
Purpose: Removes Firefox 32bit and \ or 64bit and installs a new version, defaulting to en-GB language if no parameter specified.
Be sure to rename the msi files downloaded from https://www.mozilla.org/en-GB/firefox/all/#product-desktop-release in order to signify language version.
Created by: OH
Date: 2019-09-05
Version: 1.0.0
#>

param (
    $Language  = 'en-GB'
)

$WorkingDir = Get-Location

$Firefox32BitPath = "${ENV:ProgramFiles(x86)}\Mozilla Firefox"
$Firefox64BitPath = "$ENV:ProgramFiles\Mozilla Firefox"

#Ensure that Firefox is stopped
stop-process -Name "firefox" -force -ea SilentlyContinue

#Uninstall Firefox 64bit
if (test-path "$Firefox64bitPath\uninstall\helper.exe") {
    #write-host "Removing Firefox x64"
    Start-Process "$Firefox64bitPath\uninstall\helper.exe" -ArgumentList "-ms" -NoNewWindow -Wait
    Remove-Item $Firefox64bitPath -Force -Recurse -ErrorAction SilentlyContinue
}

#Uninstall Firefox 32bit
if (test-path "$Firefox32bitPath\uninstall\helper.exe") {
    #write-host "Removing Firefox x86"
    Start-Process -FilePath "$Firefox32bitPath\uninstall\helper.exe" -ArgumentList "-ms" -NoNewWindow -Wait
    Remove-Item $Firefox32bitPath -Force -Recurse -ErrorAction SilentlyContinue
}

#Install Firefox
switch ($Language) {
    'en-GB' {start-process -FilePath "$ENV:SystemRoot\System32\msiexec.exe" -ArgumentList "/i ""$workingDir\Firefox Setup 69.0 en-GB.msi"" /qn" -NoNewWindow -Wait}
    'en-US' {start-process -FilePath "$ENV:SystemRoot\System32\msiexec.exe" -ArgumentList "/i ""$workingDir\Firefox Setup 69.0 en-US.msi"" /qn" -NoNewWindow -Wait}
    'de-DE' {start-process -FilePath "$ENV:SystemRoot\System32\msiexec.exe" -ArgumentList "/i ""$workingDir\Firefox Setup 69.0 de-DE.msi"" /qn" -NoNewWindow -Wait}
}
