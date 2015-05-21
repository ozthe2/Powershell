Migrate-Printers
----------------
Helper script to migrate our printers to new subnets.

Update-AccountStatus
--------------------
Disables staff and student accounts whose expiry date is older than today.

Track-EnabledAccounts
---------------------
Tracks the number of enabled staff acounts that have a mail attribute of "*@chichester.ac.uk" and enabled student accounts with the mail attribute of "*@student.chichester.ac.uk".  The date and the total number of staff and student accounts are then  output as a custom object so that they can be piped to other cmdlets.  An example of usage is: Track-EnabledAccounts | export-csv -NoTypeInformation -Path c:\test.csv -Append

UserUtil
--------
Tool for select staff to use in order to manage user accounts: Password changes, disable accounts, set account expiry, enable \ disable Internet access etc etc

Hide-DisabledStaffAccountsFromExchangeAddressBook
-------------------------------------------------
Sets 'msexchHideFromAddressLists' attribute to TRUE for all staff accounts in the Current OU that are disabled and have an expiry date in the past.
