<# 
.SYNOPSIS
Attach the Office 365 CDN to default asset libraries in SharePoint Online.

.DESCRIPTION
This script iterates through site collections matching a specific URL fragment and creates a private CDN 
for their default asset libraries.

.PARAMETER script_params
Refers to [name of your parameters file].xml which contains parameters for the CDNs being created.
You willl supply the value at the prompt.

.EXAMPLE
From the PowerShell prompt run .\USC_SPO_ITS_createSiteColls.ps1 You will be prompted for the path to your 
.xml parameters file.

.NOTES
18-01-08 Assembled by Ramona Maxwell - Microsoft Public License (Ms-PL) USE AT YOUR OWN RISK, you assume all 
liability for your use of any code herein. Some of the code below provided by Chris We (Microsoft).

.LINK
https://ramonamaxwell.com

.LINK
https://blogs.technet.microsoft.com/christwe/2017/08/17/sharepoint-online-and-private-cdn/
#>

#Test that parameters file loads, and contains 411
Param([string]$script_params)
$script_params = Read-Host "Please enter the path to your configuration file"
if (-not(Test-Path $script_params))
	{ 
		Write-Warning "The file containing script parameters cannot be located."
		Write-Host "The file [name of file containing site collection parameters].xml must be located in the same directory as the CreateMultipleSites script."
		return $false
	}

#Connect to SPO
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$parameters = [xml](Get-Content $script_params)
$username = read-host "Please enter your user ID"
$password = read-host "Please enter your Password" -assecurestring
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
$tenantAdminUrl = $parameters.Config.Tenant.Admin.adminURL
Connect-SPOService -Url $tenantAdminUrl -Credential $credential

#Check to see if CDN enabled in tenant, if not then enable.
if ((Get-SPOTenantCdnEnabled -CdnType $parameters.Config.Tenant.cdn.CDNtype) -eq $false) {
	try {
		Set-SPOTenantCdnEnabled -CdnType $parameters.Config.Tenant.cdn.CDNtype -Enable $true
	}
	catch {
		Write-Host $_.Exception.Message -ForegroundColor:Red
	}	
}

#https://msdn.microsoft.com/en-us/library/microsoft.sharepoint.client.listtemplatetype.aspx, https://www.codeproject.com/articles/765404/list-of-sharepoint-lists-basetemplatetype
$ReplicatedBaseTemplate = @("101","109","851") #Selecting Document, Asset and Picture Libraries

Write-Host $parameters.Config.Tenant.cdn.urlFragment "is the Url fragment being matched."
Get-SPOSite | Where-Object {$_.Url -like $parameters.Config.Tenant.cdn.urlFragment} | ForEach-Object {
	$context = New-Object Microsoft.SharePoint.Client.ClientContext($_.Url)
    $context.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($username, $password)
	$lists = $context.Web.Lists
	$context.Load($lists)  
	$context.ExecuteQuery()	

    #Must filter on Basetype = DocumentLibrary to insure we don't try to sync a list by accident
    $lists | Where-Object {$_.BaseType -eq "DocumentLibrary"} | ForEach-Object {
        if($ReplicatedBaseTemplate -contains $_.BaseTemplate)
        {
            $ListFolder = $_.RootFolder
            $context.Load($ListFolder)
            $context.ExecuteQuery()
            $LibUrl = $ListFolder.ServerRelativeUrl
            Add-SPOTenantCdnOrigin -CdnType $parameters.Config.Tenant.cdn.CDNtype -OriginUrl $liburl -Confirm:$false
        }
    }
}
#Disconnect-SPOService