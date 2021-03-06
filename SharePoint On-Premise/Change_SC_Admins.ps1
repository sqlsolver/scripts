<# 
.SYNOPSIS
Change both the primary and secondary administrators of a site collection.

.DESCRIPTION
This script replaces the current site collection administrators with new ones.

.PARAMETER siteURL
Enter the URL of the site collection, i.e. sites/thesite

.PARAMETER OwnerAlias
Enter the domain and user name domain\user

.PARAMETER SecondaryOwnerAlias 
Enter the domain and user name domain\user

.EXAMPLE
From the PowerShell prompt run .\Change_SC_Admins.ps1 or .\Change_SC_Admins.ps1 -siteUrl sites\thesite -OwnerAlias domain\user -SecondaryOwnerAlias domain\user

.NOTES
14-05-28 Assembled by Ramona Maxwell for Gilead Sciences - Internal Use Only.

.LINK
[add link to IT portal]
#>



[CmdletBinding()]
param(
[parameter(mandatory=$true)]
[string]$siteUrl,
[parameter(mandatory=$true)]
[string]$OwnerAlias,
[parameter(mandatory=$true)]
[string]$SecondaryOwnerAlias

)

Function UpdateSC_Admins{
    Write-Host -Foregroundcolor green "- Changing the site collection administrators..."
    $site = Get-SPSite | ?{$_.Url -like $siteUrl}
    If ($site -ne $null)
    {
        Set-SPSite -Identity $site.Url -OwnerAlias $OwnerAlias -SecondaryOwnerAlias $SecondaryOwnerAlias
        Write-Host -Foregroundcolor white "- Site Collection Administrators for '$site' have been changed to $OwnerAlias (primary) and $SecondaryOwnerAlias (secondary)."
    }
}
UpdateSC_Admins