Function New-BLComputer {

    # Creates new AD computer with random attributes

    # Formats:
    # Desktops = DESKTOP-<random 8 alphanumeric characters>
    # Laptops = LAPTOP-<random 8 alphanumeric characters>
    # VMs = VM-<random 8 alphanumeric characters> 
    # Servers = <function>-<random 8 alphanumeric characters>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][int32]$ComputerCount
    )

    Write-Host "[+] Creating $ComputerCount AutomatedBadLab Computers.." -ForegroundColor Green

    # Create a loop to create the specified number of computer objects
    for ($CreatedComputers= 1; $CreatedComputers -le $ComputerCount; $CreatedComputers++) {
    
        # Common variables
        $Owner = (Get-ADUser -Filter * | Get-Random).DistinguishedName
        $OUPath = (ADOrganizationalUnit -Filter * | Get-Random).DistinguishedName
        $Description = "Computer generated by AutomatedBadLab"
    
        # Make it about a 3:1 ratio of workstations to servers
        $WorkstationOrServer = 1..100 | Get-Random
        If ($WorkstationOrServer -le 75) { 
        
            # Create a workstation
            $Type = 'DESKTOP', 'LAPTOP', 'VM' | Get-Random
            $Name = "$Type-$([guid]::NewGuid().ToString().Substring(0, 8).ToUpper())"

            # Create the computer object with random attributes
            New-ADComputer -Name $Name `
                -SAMAccountName $Name `
                -DNSHostName "$Name.$((Get-AdDomain).Forest)" `
                -Enabled $True `
                -Description $Description `
                -Location "Building $(Get-Random -Minimum 1 -Maximum 10), Floor $(Get-Random -Minimum 1 -Maximum 5)" `
                -ManagedBy $Owner `
                -OperatingSystem "Windows $('XP', 'Vista', '7', '8', '8.1', '10', '11' | Get-Random)" `
                -OperatingSystemVersion "$(Get-Random -Minimum 5 -Maximum 10).0.$(Get-Random -Minimum 10000 -Maximum 12000)" `
                -OperatingSystemServicePack "Service Pack $(Get-Random -Minimum 0 -Maximum 3)" `
                -Path $OUPath
        }
        Else {

            # Create some server prefixes
            $Prefixes = @("APP", "WEB", "MAIL", "FILE", "DNS", "DC", "DHCP", "WINS", "SQL", "VPN", "PROXY", "NTP") 
            $Name = "$($Prefixes | Get-Random)-$([guid]::NewGuid().ToString().Substring(0, 8).ToUpper())"

            # Create the computer object with random attributes
            New-ADComputer -Name $Name `
                -SAMAccountName $Name `
                -DNSHostName "$Name.$((Get-AdDomain).Forest)" `
                -Enabled $True `
                -Description $Description `
                -Location "Building $(Get-Random -Minimum 1 -Maximum 10), Floor $(Get-Random -Minimum 1 -Maximum 5)" `
                -ManagedBy $Owner `
                -OperatingSystem "Windows Server $('2008', '2008 R2', '2012', '2012 R2', '2016', '2016 R2', '2019', '2019 R2', '2022' | Get-Random) $('Standard', 'Datacenter' | Get-Random)" `
                -OperatingSystemVersion "$(Get-Random -Minimum 5 -Maximum 10).0.$(Get-Random -Minimum 10000 -Maximum 25000)" `
                -OperatingSystemServicePack "Service Pack $(Get-Random -Minimum 0 -Maximum 3)" `
                -Path $OUPath
        }

        # Track progress
        Write-Progress -Id 1 -Activity "Creating AD Computers.." -Status "Creating Computer $CreatedComputers of $ComputerCount" `
        -CurrentOperation $Name -PercentComplete ($CreatedComputers / $ComputerCount * 100)
    }
}

Write-Progress -Id 1 -Activity "Created AD Computers" -Status "Completed" -PercentComplete 100 -Completed