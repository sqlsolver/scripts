<# 
.SYNOPSIS
Create new site collection(s) in SharePoint Online.

.DESCRIPTION
This script creates a new site collection, or multiple site collections from parameters specified in an external file.

.PARAMETER script_params
Refers to [name of your parameters file].xml which contains parameters for the site collections being created.
You willl supply the value at the prompt.

.EXAMPLE
From the PowerShell prompt run .\USC_SPO_ITS_createSiteColls.ps1 You will be prompted for the path to your .xml parameters file.

.NOTES
18-01-08 Assembled by Ramona Maxwell - Microsoft Public License (Ms-PL) USE AT YOUR OWN RISK, you assume all 
liability for your use of any code herein.

.LINK
https://ramonamaxwell.com
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
$parameters = [xml](Get-Content $script_params)
$username = read-host "Please enter your user ID"
$password = read-host "Please enter your Password" -assecurestring
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Connect-SPOService -Url $parameters.Config.Tenant.Admin.adminURL -Credential $credential

#Verify parameters exist for the sites being created, then create them.
$Site = $parameters.Config.Tenant.SiteColl
if($Site -ne $null) {	
		try { $Site | ForEach-Object {
			Write-Host "Now creating " $_.Url
			New-SPOSite -Url $_.Url	-StorageQuota $_.StorageQuota -Owner $_.Owner -Title $_.Title -Template $_.Template
			}
		Write-Host "Your site(s) were created successfully and should be listed in Central Administration shortly."
		}
		catch {
			Write-Host $_.Exception.Message -ForegroundColor:Red
		}		
	}
else {
		Write-Warning "Site collection creation parameters are not present in the parameters file."
		Write-Host "Ensure that the parameters file exists in the directory specified, and contains a SiteColl node."
	}