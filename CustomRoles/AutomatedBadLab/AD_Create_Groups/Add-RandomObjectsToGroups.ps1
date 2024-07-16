Function Add-RandomObjectsToGroups {

    Write-Log -Message "Randomising Group Memberships"

    # Randomly assign each ABL group to a OU
    $AllABLGroups = Get-ADGroup -Filter { Description -eq "Group generated by AutomatedBadLab" } -Properties Description
    $AllABLOus = Get-ADOrganizationalUnit -Filter { Description -eq "OU generated by AutomatedBadLab" } -Properties Description

    foreach ($ABLGroup in $AllABLGroups) {
        Move-ADObject -Identity $ABLGroup -TargetPath (($AllABLOus | Get-Random).DistinguishedName)
    }

    # Randomly assign each ABL user to a group
    $AllABLGroups = Get-ADGroup -Filter { Description -eq "Group generated by AutomatedBadLab" } -Properties Description
    $AllABLUsers = Get-ADUser -Filter { Description -eq "User generated by AutomatedBadLab" -or Description -like "Just so I dont forget my password is:*" } -Properties Description

    foreach ($ABLUser in $AllABLUsers) {
        Add-ADGroupMember -Identity ($AllABLGroups | Get-Random) -Members $ABLUser
    }

    # Randomly assign each ABL computer to a group
    $AllABLComps = Get-ADComputer -Filter { Description -eq "Computer generated by AutomatedBadLab" } -Properties Description

    foreach ($ABLComp in $AllABLComps) {
        Add-ADGroupMember -Identity ($AllABLGroups | Get-Random) -Members $ABLComp
    }

    # Nest 20% of the groups
    1..[math]::Ceiling($AllABLGroups.Count * 0.2) | ForEach-Object {
        ($AllABLGroups | Get-Random) | Add-ADGroupMember -Members ($AllABLGroups | Get-Random) -ErrorAction SilentlyContinue
    }

    # Don't want any Protected Users as causes issues with exploitation
    Get-ADGroupMember -Identity 'Protected Users' | ForEach-Object { Remove-ADGroupMember -Identity 'Protected Users' -Members $_ -Confirm:$False }
}
