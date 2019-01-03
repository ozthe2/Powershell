<#
Purpose: Removes Firefox 32bit and 64bit and then install new version
Created by: OH
Date: 2018-01-02
Version: 1.0.0
#>

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

#Install Firefox x64 based on locale
#NB default is en-US
switch ((Get-WinSystemLocale).name) {
    'en-GB' {start-process -FilePath "$workingdir\Firefox Setup 64.0-en-GB.exe" -ArgumentList "/S" -NoNewWindow -Wait -ea SilentlyContinue}
    'de-DE' {start-process -FilePath "$workingdir\Firefox Setup 64.0-de-DE.exe" -ArgumentList "/S" -NoNewWindow -Wait -ea SilentlyContinue}
    'Default' {start-process -FilePath "$workingdir\Firefox Setup 64.0-en-US.exe" -ArgumentList "/S" -NoNewWindow -Wait -ea SilentlyContinue}
}
