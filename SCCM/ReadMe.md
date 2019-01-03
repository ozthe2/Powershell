# Contents

## JavaVersionManagement.ps1
Uninstalls all existing versions of Java and then installs the new version.  
Deploy using ConfigMgr by creating a new Application of type Script Installer and then using the Installation Program of:
```powershell
powershell.exe -executionpolicy bypass -file .\JavaVersionManagement.ps1
```

## FirefoxVersionManagement.ps1
Uninstalls all existing versions (32bit and 64bit) of Firefox and then installs the new version.  
The new Firefox version installed will be in the same language as the system locale.  
Deploy using ConfigMgr by creating a new Application of type Script Installer and then using the Installation Program of:
```powershell
powershell.exe -executionpolicy bypass -file .\FirefoxVersionManagement.ps1
```

## AdobeReaderVersionManagement.ps1
Installs and patches Adobe Reader DC   
Deploy using ConfigMgr by creating a new Application of type Script Installer and then using the Installation Program of:
```powershell
powershell.exe -executionpolicy bypass -file .\AdobeReaderVersionManagement.ps1
```
