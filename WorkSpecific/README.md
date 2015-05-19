Migrate-Printers
----------------
Helper script to migrate our printers to new subnets.

Update-AccountStatus
--------------------
Disables staff and student accounts whose expiry date is older than today.

Track-EnabledAccounts
---------------------
Tracks the number of enabled staff acounts that have a mail attribute of "*@chichester.ac.uk" and enabled student accounts with the mail attribute of "*@student.chichester.ac.uk".  The date and the total number of staff and student accounts are then  output as a custom object so that they can be piped to other cmdlets.  An example of usage is: Track-EnabledAccounts | export-csv -NoTypeInformation -Path c:\test.csv -Append
