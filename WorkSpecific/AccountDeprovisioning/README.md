Typical usage of this (remove -whatif's to do live run):

Get-UserForDeProvisioning -UserType Staff -DaysExpired 360 | select -first 5 | remove-deprovisioneduser -WhatIf | Move-DeprovisionedHomeDirectories -whatif
