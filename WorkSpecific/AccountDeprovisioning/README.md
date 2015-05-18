This suite of three functions is used to deprovision expired accounts.
Each function can be used individually if required.

Get-UserForDeprovisioning
-------------------------
This uses a strict criterea to produce a list of accounts, (either staff or students), that can be deleted from Active Directory.

If you run this function by itself ie not piped anywhere, then using the switch -DoNotDisplayUsers will give you a total count of how many users would be eligible for deletion based on the figure you use in the parameter: DaysExpired

Remove-DeprovisionedUser
------------------------
This function deletes a user from Active Directory

Move-DeprovisionedHomeDirectories
---------------------------------
This moves the users home directory to a new 'holding' location where it is pending permanent manual deletion.

Get-FilesNotAccessed
--------------------
A 'sanity' check on the files that have been deemed 'deletable' by reporting if any have been accessed between xx days (specified by the parameter) and todays date.


Typical usage of this suite:
----------------------------
(For Testing purposes:)
Get-UserForDeProvisioning -UserType Staff -DaysExpired 360 | select -first 5 | remove-deprovisioneduser -WhatIf | Move-DeprovisionedHomeDirectories -whatif

(For actual deprovisioning)
Get-UserForDeProvisioning -UserType Staff -DaysExpired 360 | remove-deprovisioneduser | Move-DeprovisionedHomeDirectories

Followed by:
Get-FilesNotAccessed -UserType Student -DaysSinceLastAccessed 260 -Verbose
To get student files that may have been recently accessed

Get-FilesNotAccessed -UserType Staff -Verbose
To get student files that may have been recently accessed
