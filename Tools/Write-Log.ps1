function Write-Log {

<#
.SYNOPSIS
Creates \ writes logs.
.DESCRIPTION
Allows you to create and write \ append to new or existing log files.  
Can also append the date to the filename and write the current date & time to the log.
By default the log will write in 'Append' mode to c:\Powershell\logs and append the current date to the logname unless specified otherwise.
.PARAMETER Message
This is the message that you would like written to the log.  
It can be either text or a variable. You can also send a space to act as a carrriage-return.
.PARAMETER  LogLocation
The path to where you wish to store the log.  If the path does not exist, then it will create it for you.  You can either append a backslash to the path or leave it out.
.PARAMETER  LogName
The name of the log without an extension. Include only alphanumeric characters and the symbols . _ or - (period, underscore or hyphen)	
.PARAMETER LogExtension
By default, the logname will have .log appended to it, however you can also select .err and .dat	
.PARAMETER  DoNotAddDateToLogName
By default, the name of your log will be appended with the actual real date that you run the script in the format _ddmmyyyy, however if you specify this switch then this will not happen.    
.PARAMETER  Overwrite
By default, the log will write in append mode unless you specify this switch.  If you specifiy this switch then any existing log of the same name will be overwritten.
.PARAMETER  LogDateTime
If you specify this switch it will write the current date and time to the log.
.EXAMPLE
Write a message to a logfile called: 'UserData' at the location \\Server\Share\Logs.  If the location does not exist then it will be created.  Write the message contained in the variable $MyLogMessage.  If the log already exists then append the message.
write-log -message $MyLogMessage -LogLocation \\Server\Share\Logs -LogNameUserData
.EXAMPLE
Write a log named LogData with the message "My Error" at the default location of C:\Powershell\Logs and give the log the extension of .err, also do not append the date to the name of the log
write-log -message "My Error" -LogName "Log Errors" -LogExtension .err -DoNotAddDateToLogName
.EXAMPLE
Overwrite the specified log with a message showing the date and time the log was overwritten
Write-Log -message "Overwritten at: " -LogName test -LogLocation C:\Powershell\Logs -Overwrite -LogDateTime
.EXAMPLE
Append just the date and time to the logfile c:\Powershell\Logs\Test.log
Write-Log -LogName Test -LogLocation c:\Powershell\Logs -LogDateTime
.EXAMPLE
Full example of how you might format a log file named 'Test' stored at C:\Powershell\Logs:
        
#Add a line break
Write-Log -message " " -LogName test -LogLocation C:\Powershell\Logs
#Add some prettying up!
Write-Log -message "****************************************" -LogName test -LogLocation C:\Powershell\Logs
#Add a log start time
Write-Log -message "Start processing at: " -LogName test -LogLocation C:\Powershell\Logs -LogDateTime
#Add some prettying up!
Write-Log -message "****************************************" -LogName test -LogLocation C:\Powershell\Logs
#Add log messages
Write-Log -message "Message1" -LogName test -LogLocation C:\Powershell\Logs
Write-Log -message $MyVar -LogName test -LogLocation C:\Powershell\Logs
Write-Log -message "Message3" -LogName test -LogLocation C:\Powershell\Logs
#Add some prettying up!
Write-Log -message "****************************************" -LogName test -LogLocation C:\Powershell\Logs
#Add log end time:
Write-Log -message "End processing at: " -LogName test -LogLocation C:\Powershell\Logs -LogDateTime
#Add some prettying up!
Write-Log -message "****************************************" -LogName test -LogLocation C:\Powershell\Logs
.INPUTS
    None.  You cannot pipe objects to Write-Log
.NOTES
Version: 2.0
Date: 8 September 2014
Created By: OH
.LINK
http://www.fearthemonkey.co.uk
.LINK
https://github.com/ozthe2/Powershell.git
#>


    [CmdletBinding(                  
                  ConfirmImpact='Medium')]
    [OutputType([String])]
    Param
    (
        # Param1
        [parameter(Mandatory=$false,
                   Position=0)]                           
        [String]
        $Message = "",

        # Param2
        [parameter(Mandatory=$false)]                   
        [String]
        $LogLocation = "\\server\path\to\Logs",

        # Param3
        [parameter(Mandatory=$false)]
        [ValidateScript({
            # Let's have a more meaningful error message for those of us who don't read regex!
            If ($_ -match "^[a-zA-Z0-9_ .-]+$") {
                $True
            }
            else {
                Throw "The logname '$_' must contain at least one character and can only contain alphanumeric characters or the symbols _ or . or -"
            }
        })]  
        [ValidateLength(1,35)]       
        [String]
        $LogName = "NewStudentCreateU",

        #Param4
        [parameter(Mandatory=$false)]
        [ValidateSet(".log",".err",".dat")]
        [String]
        $LogExtension = ".log",

        #Param5
        [parameter(Mandatory=$false)]                   
        [Switch]        
        $DoNotAddDateToLogName,

        #Param6
        [parameter(Mandatory=$false)]                   
        [Switch]        
        $Overwrite,

        #Param6
        [parameter(Mandatory=$false)]                   
        [Switch]        
        $LogDateTime

    ) #End Param

    Begin {    
        # Verify Log Location exists
        if (!(test-path -Path $LogLocation -PathType Container)) {
        #The Log location does not exist...attempt to create the location specified...
            try {
                New-Item -Path $LogLocation -ItemType directory -ErrorAction Stop -ErrorVariable x
            } 
            catch {
                Write-Error "An error occured while trying to create the directory $LogLocation that prevents this script from continuing."
                Write-error "The error encountered was: $x"
            }      
        } #End if

        # Date in logname:
        # By default, the date will be added to the name of the log file unless the switch -DoNotAddDateToLogName has been specified.        
        if (!($DoNotAddDateToLogName)) {            
            $logname += (Get-Date).ToString("_dd-MM-yyyy")
        }  
        
        #Logname file extension:
        # By default, the log name will have the .log extension unless specified otherwise by the -LogExtension parameter.        
        switch ($LogExtension) {
            '.err' {$logname+='.err'}
            '.dat' {$logname+='.dat'}
            default {$logname+='.log'}
        } #End switch

    } #End Begin
    
    Process {  
        $now = get-date -Format dd/MM/yyyy
        
        #Write the log...
        if ($Overwrite) { 
            if ($LogDateTime) {
                $message + " " + (Get-Date -Format dd-MMMM-yyyy_HH.mm.ss) | Out-File -FilePath (Join-Path -Path $LogLocation -ChildPath $LogName) -force
            } else {
                $Message | Out-File -FilePath (Join-Path -Path $LogLocation -ChildPath $LogName) -force                       
              }  
        }
        else {
            if ($LogDateTime)  {
                $message + " " + (Get-Date -Format dd-MMMM-yyyy_HH.mm.ss) | Out-File -FilePath (Join-Path -Path $LogLocation -ChildPath $LogName) -Append                                              
            } else {                        
                $Message | Out-File -FilePath (Join-Path -Path $LogLocation -ChildPath $LogName) -Append
              }      
        }        
    } #End Process

    End{}       
       
} # End Function
