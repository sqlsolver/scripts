<# 
.SYNOPSIS
Create a new site collection.

.DESCRIPTION
This script creates a new site collection, or multiple site collections from parameters 
specified in an external file..

.PARAMETER sc_params
Refers to [name of your parameters file].xml which contains parameters for the site collections 
being created.

.EXAMPLE
From the PowerShell prompt run .\CreateMultipleSites.ps1 or 
.\CreateMultipleSites.ps1 -parameters .\[the name of your parameters file].xml

.NOTES
14-07-01 Assembled by Ramona Maxwell for Gilead Sciences - Internal Use Only.

.LINK
[add link to IT portal]
#>

Param([string]$sc_params)
function Get-Parameters()
{
	<#
	.SYNOPSIS
	Loads and validates the XML file containing the script parameters.

	.DESCRIPTION
	This function will load and validate the script parameters.
	
	#>
	
	# Verify the configuration file exists
	if (-not(Test-Path $sc_params))
	{ 
		Write-Warning "The file containing script parameters cannot be located."
		Write-Host "The file [name of file containing site collection parameters].xml must be located in the same directory as the CreateMultipleSites script." -ForegroundColor:Green
		return $false
	}

	# Get the parameters for the sites being created
	$parameters = [xml](Get-Content $sc_params)
	$SiteCollsConfig = $parameters.SiteColls.SiteColl
	if($SiteCollsConfig -eq $null)
	{
		Write-Warning "Site collection creation parameters are not present in the parameters file."
		Write-Host "Ensure that the parameters file contains a <SiteColl> node." -ForegroundColor:Purple
		return $false
	}
	return $SiteCollsConfig
	}
	# Create the sites
	try {
		Get-Parameters | foreach {
		$NewSiteCollConfig = $_
		$NewSiteColl = New-SPSite $NewSiteCollConfig.SiteCollUrl`  
			-Name $NewSiteCollConfig.Name`
			-Template $NewSiteCollConfig.Template`
			-ContentDatabase $NewSiteCollConfig.ContentDatabase`
			-Description $NewSiteCollConfig.Description` 
			-OwnerAlias $NewSiteCollConfig.OwnerAlias`
			-OwnerEmail $NewSiteCollConfig.OwnerEmail`
			-SecondaryOwnerAlias $NewSiteCollConfig.SecondaryOwnerAlias`
			-SecondaryOwnerEmail $NewSiteCollConfig.SecondaryOwnerAlias`
			-Language $NewSiteCollConfig.Language
			 
		Write-Host "The site collection $NewSiteCollConfig.Name has been created!" -ForegroundColor:Yellow
	}
	}
	catch {
		Write-Host $_.Exception.Message -ForegroundColor:Red}