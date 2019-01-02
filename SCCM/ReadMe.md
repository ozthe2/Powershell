# Contents

## JavaVersionManagement.ps1
Uninstalls all existing versions of Java and then installs the new version.  
Deploy using ConfigMgr by creating a new Application of type Script Installer and then using the Installation Program of:
```powershell
powershell.exe -executionpolicy bypass -file .\JavaVersionManagement.ps1
```
