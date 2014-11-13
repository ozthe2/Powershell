function Get-TimeDifference {
    [CmdletBinding()]
    [OutputType('MyType.TimeDiff')]    
    Param(              
        [PARAMETER(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]        
        [string]
        $StartTime = (Get-Date -format HH:mm:ss),

        [PARAMETER(Mandatory=$false,
        ValueFromPipelineByPropertyName=$true)]
        [string]
        $EndTime = (Get-Date -format HH:mm:ss)
    )

    PROCESS {
        [PSCustomObject] @{
            StartTime = $StartTime
            EndTime = $EndTime
            TimeDifference = (New-TimeSpan $StartTime $EndTime).ToString()
            PSTypename = 'MyType.TimeDiff'
        }
    }
}#end function

#Read TS Vars
$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$tsname = $tsenv.value("_SMSTSPackageName")

$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$ImageStartTime = $tsenv.value("StartTime")

$tsenv = New-Object -ComObject Microsoft.SMS.TSEnvironment
$ImageName = $tsenv.value("ImageName")

#Get the time difference
$tDiff = Get-TimeDifference -StartTime $ImageStartTime


#Create the reg Key
New-Item -Path HKLM:\System\CSU\Imaging -force

#Add The date of imaging
New-ItemProperty -path HKLM:\System\CSU\Imaging -name 'ImageDate' -Value (get-date -format dd-MMM-yyyy) -PropertyType string -force

#Add The start time of imaging
New-ItemProperty -path HKLM:\System\CSU\Imaging -name 'ImageStartTime' -Value $ImageStartTime -PropertyType string -force

#Add The End Time of imaging
New-ItemProperty -path HKLM:\System\CSU\Imaging -name 'ImageEndTime' -Value (get-date -Format HH:mm:ss) -PropertyType string -force

#Add The Total Imaging Time
New-ItemProperty -path HKLM:\System\CSU\Imaging -name 'TotalImageTime' -Value $($tDiff.timedifference) -PropertyType string -force

#Add The name of the task sequence
New-ItemProperty -path HKLM:\System\CSU\Imaging -name 'TaskSequence' -Value $tsname -PropertyType string -force

#Add The image name of the task sequence
New-ItemProperty -path HKLM:\System\CSU\Imaging -name 'ImageName' -Value $ImageName -PropertyType string -force
