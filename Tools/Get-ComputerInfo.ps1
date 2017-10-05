<#
.SYNOPSIS
    Gets computer information such as Network details and Operating system installed
.DESCRIPTION
    By default, this will pull basic but fundamental info from the computer such as OS, Network details eg IP \ Subnet etc, Virtual or not etc.  By adding the -Detailed switch, more information will be gathered.
    Use the -verbose switch to see which computers failed the connection test.
.PARAMETER ComputerName
    The name of the computer that you wish to probe
.PARAMETER Detailed
    When you use this switch, additional info will be obtained: Disk, BIOS and Processor information
.EXAMPLE
    Get-ComputerInfo -ComputerName MyComputer -Detailed
    The detailed computer information of 'MyComputer' will be displayed on screen.
.EXAMPLE
    'computer1','computer2' | Get-ComputerInfo
    The computer information of 'Computer1' and 'Computer2' will be displayed on screem.  It will not contain BIOS, Dis or CPU info as the -Detailed switch has not been used.
.EXAMPLE
    (get-adcomputer -filter * -SearchBase 'ou=servers,ou=MyOU,dc=mydomain,dc=local').name  | Get-ComputerInfo -Detailed | export-csv C:\Output.csv -NoTypeInformation
    The computer objects in the OU obtained by 'Get-ADComputer' will have all available computer informationwill be output to a CSV file.
.EXAMPLE
    servers.txt | Get-ComputerInfo -detailed
    The computernames contained in Servers.txt will be used as the input of the command and all available computer information will be displayed.
.NOTES
Version 1
By: OzThe2
.LINK
https://www.fearthemonkey.co.uk
#>
Function Get-ComputerInfo {
    [CmdletBinding()]
    param(  
        [Parameter(
        ValueFromPipelineByPropertyName=$true,
        ValueFromPipeline=$true)]
        [string[]]$ComputerName = $env:COMPUTERNAME,
        [switch]$Detailed
    ) 

    begin {}

    process {
        foreach ($Computer in $ComputerName) {            
            try {
                $Continue = $true                
                Write-Verbose "Trying computer: $Computer."
                #Let's try a generic wmi call to the computer to ensure that we can connect
                $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer -ErrorAction stop

	        } catch {
		        $Continue = $false 
                Write-Verbose "$Computer failed connection."
                #Write-Error $_.Exception.Message
	        }

            #If the WMI call succeeded, lets do it...
            if ($Continue) {
                Write-Verbose "Connection to computer: $Computer successful - Trying next WMI calls."                
                $net = Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $Computer
                $bios = Get-WmiObject Win32_Bios -ComputerName $Computer
                $comp = Get-WmiObject Win32_ComputerSystem -ComputerName $Computer
                $proc = Get-WmiObject Win32_processor -ComputerName $Computer
                $diskinfo = Get-WmiObject Win32_LogicalDisk -ComputerName $Computer -filter "drivetype = 3"

                #Create custom object
                $Obj = [pscustomobject]@{
                            'Computername'   = $Computer.toupper()
                            'OS Version'     = $os.caption
                            'OSBuild'        = $os.buildNumber
                            'SPVersion'      = $os.ServicePackMajorVersion
                            'OSArchitecture' = $os.osarchitecture
                            'Manufacturer'   = $comp.manufacturer
                            'Model'          = $comp.model                
                        }#Custom object                

                #Get network info and add to the custom object
                foreach ($Network in $net) {
                    if ($network.ipaddress -eq $NULL) {
                        continue
                    } else {
                        $obj | Add-Member -MemberType NoteProperty -Name "IPAddressIndex($($network.index[0]))"  -value $($Network.index[0])                        
                    }
                    
                    if ($network.ipaddress -eq $NULL) {
                        continue
                    } else {
                        $obj | Add-Member -MemberType NoteProperty -Name "IPAddress($($network.index[0]))"  -value $($Network.ipaddress[0])                        
                    }
                    
                    if ($network.ipsubnet -eq $NULL) {
                        $obj | Add-Member -MemberType NoteProperty -Name "Subnet($($network.index[0]))"  -value ""
                    } else {                        
                        $obj | Add-Member -MemberType NoteProperty -Name "Subnet($($network.index[0]))"  -value $($Network.ipsubnet[0])
                    }

                    if ($network.defaultipgateway -eq $NULL) {
                        $obj | Add-Member -MemberType NoteProperty -Name "Gateway($($network.index[0]))"  -value ""
                    } else {                        
                        $obj | Add-Member -MemberType NoteProperty -Name "Gateway($($network.index[0]))"  -value $($Network.defaultipgateway[0])
                    }

                    if ($network.dhcpenabled -eq $NULL) {
                        $obj | Add-Member -MemberType NoteProperty -Name "DHCPEnabled($($network.index[0]))"  -value "False"
                    } else {                        
                        $obj | Add-Member -MemberType NoteProperty -Name "DHCPEnabled($($network.index[0]))"  -value $($Network.dhcpenabled[0])
                    }

                    if ($network.dnsserversearchorder -eq $NULL) {
                        $obj | Add-Member -MemberType NoteProperty -Name "DNS($($network.index[0]))"  -value ""
                    } else {                        
                        $obj | Add-Member -MemberType NoteProperty -Name "DNS($($network.index[0]))"  -value (@($Network.dnsserversearchorder) -join ',')
                    }

                    if ($network.MACAddress -eq $NULL) {
                        $obj | Add-Member -MemberType NoteProperty -Name "MAC($($network.index[0]))"  -value ""
                    } else {                        
                        $obj | Add-Member -MemberType NoteProperty -Name "MAC($($network.index[0]))"  -value $($Network.MACAddress)
                    }
            
                }# foreach $network 

                if ($Detailed) {
                    #Disk info
                    Foreach ($Disk in $diskinfo) {
                        $size = ([math]::round(($disk.size/1GB),2))
                        $free = ([math]::round(($disk.freespace/1GB),2))

                        $obj | Add-Member -MemberType NoteProperty -Name "DiskSize($($disk.deviceid))"  -value "$size GB"
                        $obj | Add-Member -MemberType NoteProperty -Name "DiskFreespace($($disk.deviceid))"  -value "$free GB"
                    }

                    #Bios info
                    $obj | Add-Member -MemberType NoteProperty -Name "BIOSMake"  -value (@($bios.biosversion) -join ',')
                    $obj | Add-Member -MemberType NoteProperty -Name "BIOSVerion"  -value "$($bios.SMBIOSBIOSVersion).$($bios.SMBIOSMajorVersion).$($bios.SMBIOSMinorVersion)"

                    #Processor info
                    foreach ($Processor in $proc) {
                        $obj | Add-Member -MemberType NoteProperty -Name "ProcessorID($($processor.deviceID))"  -value $Processor.DeviceID
                        $obj | Add-Member -MemberType NoteProperty -Name "ProcessorCaption($($processor.deviceID))"  -value $Processor.Caption
                        $obj | Add-Member -MemberType NoteProperty -Name "ProcessorName($($processor.deviceID))"  -value $Processor.Name
                        $obj | Add-Member -MemberType NoteProperty -Name "ProcessorSpeed($($processor.deviceID))"  -value $Processor.MaxClockSpeed
                        $obj | Add-Member -MemberType NoteProperty -Name "ProcessorCores($($processor.deviceID))"  -value $Processor.NumberOfCores
                        $obj | Add-Member -MemberType NoteProperty -Name "ProcessorLogicalProcessors($($processor.deviceID))"  -value $Processor.NumberOfLogicalProcessors
                    }
                }#if $detailed

                $obj


            }#if $Continue
        }#For Each $computer in $computername
    }#process

    end {}
}#function

Get-ComputerInfo