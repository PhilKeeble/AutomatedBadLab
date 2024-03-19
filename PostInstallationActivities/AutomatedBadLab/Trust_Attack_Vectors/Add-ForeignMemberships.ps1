Function Add-ForeignMemberships {

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)][Object[]]$VulnUsers
    )

    Write-Host "  [+] Creating Cross Domain Memberships on $((Get-ADDomain).DNSRoot)" -ForegroundColor Green

    # Get all AutomatedBadLab groups that can accept foreign memberships
    $LocalBLGroups = @(Get-ADGroup -Filter "GroupScope -eq 'DomainLocal' -and GroupCategory -eq 'Security' -and Description -eq 'Group generated by AutomatedBadLab'" -Properties GroupScope, GroupCategory, Description)

    # Retrieve trusted domains
    $TrustedDomains = (Get-ADTrust -Filter *).Name
   
    # Add foreign user to local group memberships
    While ($ForeignGroupMemberships -lt $LocalBLGroups.Count) {

        # Get random vulnerable user
        $ForeignVulnUser = $VulnUsers | Get-Random

        # Get the users domain
        $ForeignVulnUserDomain = $ForeignVulnUser.UserPrincipalName.Split('@')[-1]

        # Make sure its a foreign user from a trusted domain
        If ($ForeignVulnUserDomain -eq $env:USERDNSDOMAIN -or $ForeignVulnUserDomain -notin $TrustedDomains) {
            Continue
        }
       
        # Create foreign user -> local group membership
        $ForeignVulnUser = Get-ADUser -Identity $ForeignVulnUser.SamAccountName -Server $ForeignVulnUserDomain
        $LocalBLGroup = $LocalBLGroups | Get-Random

        try {
            Add-ADGroupMember -Identity $LocalBLGroup -Members $ForeignVulnUser
            Write-Host "    [+] $ForeignVulnUser is a member of $LocalBLGroup" -ForegroundColor Yellow
            $ForeignGroupMemberships++
        } catch {
            Write-Host "    [!] $ForeignVulnUser could not be added to $LocalBLGroup" -ForegroundColor Red
        }

        # Create foreign group -> local group membership
        $ForeignGroup = Get-ADGroup -Server $ForeignVulnUserDomain -Filter "Description -eq 'Group generated by AutomatedBadLab'" -Properties Description | Get-Random
        $LocalBLGroup = $LocalBLGroups | Get-Random

        try {
            Add-ADGroupMember -Identity $LocalBLGroup -Members $ForeignGroup
            Write-Host "      [+] $ForeignGroup is a member of $LocalBLGroup" -ForegroundColor Yellow
        } catch {
            Write-Host "      [!] $ForeignGroup could not be added to $LocalBLGroup" -ForegroundColor Red
        }
    }
}

Add-ForeignMemberships -VulnUsers $VulnUsers
