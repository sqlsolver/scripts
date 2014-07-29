<# 
.SYNOPSIS
Create multiple sites within a site collection.

.DESCRIPTION
This script creates multiple webs in a site collection based on a the template you specify for each site. 
This script should not be edited, the site details can be edited in the parameters file.

.PARAMETER file
Refers the path to an .XML file which contains parameters for individual sites being created.

.EXAMPLE
From the PowerShell prompt run .\CreateMultipleSites.ps1 -file .\[enter the name of your parameters file].xml

.NOTES
14-05-28 Assembled by Ramona Maxwell for Gilead Sciences - Internal Use Only.

.LINK
[add link to IT portal]
#>

Param([string]$file) 
function Get-Parameters(){
	<#
	.SYNOPSIS
	Loads and validates the XML file containing the script parameters.

	.DESCRIPTION
	This function will load and validate the script parameters.
	
	#>
	  
	# Verify the configuration file exists
	
	if (-not(Test-Path $file)){ 
		Write-Warning "The file containing script parameters cannot be located."
		Write-Host "The file to create the script parameters must be located in the same directory as the CreateMultipleSites script." -ForegroundColor:Green
		return $false
		}
	#Load and validate the configuration file
	[xml]$WebParams = Get-Content $file
	$newWebParams = $WebParams.SiteColl.Web
		if($newWebParams -eq $null){
			Write-Warning "Site creation parameters are not present in the parameters file."
			Write-Host "Ensure that the parameters file contains a <Web> node." -ForegroundColor:DarkMagenta
			return $false
		}		
	return $newWebParams	
}	

try {
	Get-Parameters | ForEach-Object {
	$newWebConfig = $_
		$newWeb = New-SPWeb $newWebConfig.Url`
		-Name $newWebConfig.Name`
		-Description $newWebConfig.Description`
		-UseParentTopNav:([System.Convert]::ToBoolean($newWebConfig.UseParentTopNav))`
		-AddToQuickLaunch:([System.Convert]::ToBoolean($newWebConfig.AddToQuickLaunch))`
		-UniquePermissions:([System.Convert]::ToBoolean($newWebConfig.UniquePermissions))`
 		-Language $newWebConfig.LCID
		
		$parentSite = Get-SPWeb -Site $newWebConfig.ParentUrl
		$templates = New-Object "System.Collections.ObjectModel.Collection``1[[Microsoft.SharePoint.SPWebTemplate, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c]]"
		$availableWebTemplates = $parentSite.GetAvailableWebTemplates($newWebConfig.LCID);
		$parentSite.AllowAllWebTemplates()
		$availableWebTemplates | ForEach-Object {
			$templates.add($_)
			$parentSite.SetAvailableWebTemplates($templates, $newWebConfig.LCID);
			$parentSite.Update()
		}
		$newWeb.ApplyWebTemplate($newWebConfig.Template)
		Write-Host "The website $newWeb has been created!" -ForegroundColor:Yellow
	}
}
catch  [System.Management.Automation.PSArgumentException]{
	Write-Host $_.Exception.Message -ForegroundColor:Red | Format-Table -AutoSize
	}
finally {
Write-Host "Script execution has completed."
}