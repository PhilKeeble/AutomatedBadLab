﻿Function New-KerberoastableUser {

    # Adds SPNs for given number of AD Objects

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][int32]$KerbUserCount
    )

    Write-Host "  [+] Configuring $KerbUserCount Users to be Kerberoastable" -ForegroundColor Green
    
    $KerbUsers = New-Object 'System.Collections.Generic.List[Microsoft.ActiveDirectory.Management.ADUser]'
    $ServiceClass = @("HTTP", "HOST", "TERMSRV", "MSSQLSvc", "CIFS", "POP3")
        
    for ($Counter = 1; $Counter -le $KerbUserCount; $Counter++) {
        $BLComputer = (Get-ADComputer -Filter 'Description -like "*AutomatedBadLab*"' | Get-Random).DNSHostName
        $BLUser = Get-ADUser -Filter {Description -like "*AutomatedBadLab*" -and ServicePrincipalNames -notlike "*"} -Property ServicePrincipalNames | Get-Random
        $SPN = "$($ServiceClass | Get-Random)/$BLComputer"

        Write-Host "    [+] $BLUser is Kerberostable with SPN: '$SPN'" -ForegroundColor Yellow
            
        Try { 
            $BLUser | Set-ADUser -ServicePrincipalNames @{Add = $SPN } -ErrorAction Stop
            $KerbUsers += $BLUser
        }
        Catch { 
            # Error, try again with a different user
            $Counter--
        }  
    }
    
    # Return the number of users that were made Kerberoastable
    return $KerbUsers
}
