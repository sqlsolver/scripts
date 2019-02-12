﻿<#
.SYNOPSIS
   Sets the Object Caching accounts

.DESCRIPTION
   Sets the 2 user accounts (Portal Super User and Portal Super Reader) for the Object
   Caching for a webapplication.
   Requires 2 existing domain accounts.
   NOTE: Must run as admin who has both owner and security admin roles on SP database.

.NOTES
   File Name: Add-WebApplicationPolicy.ps1
   Version  : 1.0

.PARAMETER Webapplication
   Specifies the URL of the web application where the users are added to.

.PARAMETER Superuser
   Specifies the domain account for the Portal Super User in the format 'domain\username'.

.PARAMETER Superreader
   Specfies the domain account for the Portal Super Reader in the format 'domain\username'.

.EXAMPLE  
   PS > .\Add-WebApplicationPolicy.ps1 -Webapplication http://intranet.westeros.com -Superuser westeros\suser -Superreader westeros\sreader

   Description
   -----------  
   This script gives the westeros\suser account "Full Control" and the westeros\sreader account
   "Full Read" permissions on the specified webapplication
#>
[CmdletBinding()]
param(
   [parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
   [string]$Webapplication,
   [parameter(Position=1,Mandatory=$true,ValueFromPipeline=$false)]
   [string]$Superuser,
   [parameter(Position=2,Mandatory=$true,ValueFromPipeline=$false)]
   [string]$Superreader
)

# Load SharePoint snapin if needed
if ((Get-PSSnapin -Name Microsoft.SharePoint.PowerShell -EA SilentlyContinue) -eq $null)
{
   Write-Host "Loading SharePoint cmdlets..."
   Add-PSSnapin Microsoft.SharePoint.PowerShell
}

# Validate parameters
$webApp = Get-SPWebApplication $Webapplication
if ($webApp -eq $null)
{
   Write-Host "'$webapplication' is not a valid SharePoint webapplication"
   break
}

# Convert plain user names to Claims if the webapp uses Claims Based authentication
if ($webApp.UseClaimsAuthentication)
{
   $cpSUser = New-SPClaimsPrincipal -Identity $Superuser -IdentityType WindowsSamAccountName
   $Superuser = $cpSUser.ToEncodedString()
   $cpSReader = New-SPClaimsPrincipal -Identity $Superreader -IdentityType WindowsSamAccountName
   $Superreader = $cpSReader.ToEncodedString()
}

# Check if a Web Application Policy already exists for the Portal Super User Account
$policy = $webApp.Policies | ? {$_.UserName.ToLower() -eq $Superuser.ToLower()}
if ($policy -eq $null)
{
   $zp = $webApp.ZonePolicies("Default")
   $policy = $zp.Add($Superuser, "Portal Super User Account")
   $fc = $webApp.PolicyRoles.GetSpecialRole("FullControl")
   $policy.PolicyRoleBindings.Add($fc)
   $webApp.Properties["portalsuperuseraccount"] = $Superuser
   $webApp.Update()
}
else
{
   Write-Host "Policy for $Superuser already exists"
}

# Check if a Web Application Policy already exists for the Portal Super Reader Account
$policy = $webApp.Policies | ? {$_.UserName.ToLower() -eq $Superreader.ToLower()}
if ($policy -eq $null)
{
   $zp = $webApp.ZonePolicies("Default")
   $policy = $zp.Add($Superreader, "Portal Super Reader Account")
   $fc = $webApp.PolicyRoles.GetSpecialRole("FullRead")
   $policy.PolicyRoleBindings.Add($fc)
   $webApp.Properties["portalsuperreaderaccount"] = $Superreader
   $webApp.Update()
}
else
{
   Write-Host "Policy for $Superreader already exists"
}