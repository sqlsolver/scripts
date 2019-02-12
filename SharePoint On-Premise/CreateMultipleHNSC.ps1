<# 
.SYNOPSIS
Create Host Named Site Collections in a Web Application.

.DESCRIPTION
Can be called during initial farm configuration and when adding new site collections. 
Host Named Site Collections can only be added through PowerShell.

.PARAMETER Parameters
A required parameter, an XML file containing parameter values.

.EXAMPLE
.\CreateMultipleHNSC.ps1

.NOTES
2013-04-10 Assembled by Ramona Maxwell, MCPD SharePoint 2010 - Ramona@SharePointSolver.com @sqlsolver

.LINK
http://www.SharePointSolver.com
#>

function Get-Parameters()
{
	<#
	.SYNOPSIS
	Loads and validates the XML file containing the script parameters.

	.DESCRIPTION
	This function will load and validate the .\Parameters.xml file.
	
	#>
	
	# Verify the configuration file exists
	if (-not(Test-Path .\Parameters.xml))
	{ 
		Write-Warning "The file containing script parameters cannot be located."
		Write-Host "     The Parameters.xml file must be located in the same directory as the CreateMultipleHNSC script." -ForegroundColor:Green
		return $false
	}

	# Get the managed metadata configuration
	[xml]$parameters = Get-Content .\Parameters.xml
	$SiteCollsConfig = $parameters.Config.SiteColls
	if($SiteCollsConfig -eq $null)
	{
		Write-Warning "Site collection creation parameters are not present in the Parameters.xml file."
		Write-Host "     Ensure that the Parameters.xml file contains a <SiteColls> node." -ForegroundColor:Purple
		return $false
	}
	return $SiteCollsConfig
}
Get-Parameters
try {
	$SiteCollsConfig.SiteColl | foreach {
New-SPSite $SiteCollsConfig.SiteColl.SiteUrl -HostHeaderWebApplication $SiteCollsConfig.SiteColl.HostHeaderWebApplication -Name $SiteCollsConfig.SiteColl.Name -Description $SiteCollsConfig.SiteColl.Description -OwnerAlias $SiteCollsConfig.SiteColl.OwnerAlias -Template $SiteCollsConfig.SiteColl.Template 
Write-Host "Site Collection $SiteCollsConfig.SiteColl.Name has been created!" -ForegroundColor:Yellow
	}
}
catch {
		Write-Host $_.Exception.Message -ForegroundColor:Red
	}

#Fix the IIS bindings for the HNSCs
try {
$SiteCollsConfig.SiteColl | foreach {
Import-Module WebAdministration
New-WebBinding -Name $SiteCollsConfig.SiteColl.HostHeaderNameToBind -HostHeader $SiteCollsConfig.SiteColl.SiteCollHeader 
}
}
catch {
		Write-Host $_.Exception.Message -ForegroundColor:Red} 
#end script 