#Used for 'pinging' a device/devices
#Author: OH

function Ping-Device {

[OutputType('MyTypes.PingDevice')]
[CmdletBinding()]

Param (      
    [parameter(ValueFromPipeline=$true,
               Mandatory=$true)]
    [String[]]
    $ComputerName  
)

    process {
        foreach ($comp in $computername) {
            [PSCustomObject] @{
                server = $comp
                IsAlive = test-connection -ComputerName $comp -Quiet -Count 1
                Time = get-date -Format "HH:mm"               
                PSTypename = 'MyTypes.PingDevice'
            }  
        }#end foreach
    }#end process
}#end function

#Testing
#ping-device (Get-Content c:\servers.txt)| where 'isalive' -eq $false
