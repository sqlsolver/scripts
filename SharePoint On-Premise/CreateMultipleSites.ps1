<# 
.SYNOPSIS
Create a new site collection.

.DESCRIPTION
This script creates a new site collection along with its content database, or multiple site collections from parameters 
specified in an external file.

.PARAMETER sc_params
Refers to [name of your parameters file].xml which contains parameters for the site collections 
being created. You willl supply the value at the prompt.

.EXAMPLE
From the PowerShell prompt run .\CreateMultipleSites.ps1 You will be prompted for the path to your .xml paraameters file.

.NOTES
16-02-11 Assembled by Ramona Maxwell www.SolverInc.com/contact - Microsoft Public License (Ms-PL) USE AT YOUR OWN RISK, you assume all 
liability for your use of any code herein.

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
    $sc_params = Read-Host "Please enter the path to your configuration file"
	if (-not(Test-Path $sc_params))
	{ 
		Write-Warning "The file containing script parameters cannot be located."
		Write-Host "The file [name of file containing site collection parameters].xml must be located in the same directory as the CreateMultipleSites script."
		return $false
	}

	# Get the parameters for the sites being created
	$parameters = [xml](Get-Content $sc_params)
	$SiteCollsConfig = $parameters.config.SiteColls.SiteColl
	if($SiteCollsConfig -eq $null)
	{
		Write-Warning "Site collection creation parameters are not present in the parameters file."
		Write-Host "Ensure that the parameters file contains a <SiteColl> node."
		return $false
	}
	return $SiteCollsConfig
	}
	# Create the sites
    
	try {
        #Get the web application
        $webApp = Read-Host "Please enter the name of web application where you would like the site collection(s) created"

		Get-Parameters | ForEach-Object {
        New-SPContentDatabase -Name $_.ContentDatabase -WebApplication $webApp -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 100
		$NewSiteColl = New-SPSite -Url $_.Url`
			-Name $_.Name`
			-Template $_.Template`
			-ContentDatabase $_.ContentDatabase`
			-Description $_.Description`
			-OwnerAlias $_.OwnerAlias`
			-OwnerEmail $_.OwnerEmail`
			-SecondaryOwnerAlias $_.SecondaryOwnerAlias`
			-SecondaryEmail $_.SecondaryEmail`
			-Language $_.Language
			Start-Sleep -Seconds 30
			$validatedSite = Get-SPSite -Identity $_.Url
			If ($validatedSite) {				
				Write-Host "The site collection $validatedSite has been created!" -ForegroundColor:Yellow
				Write-Host $validatedSite.RootWeb.SiteGroups -ForegroundColor:DarkBlue
				$u1 = $validatedSite.RootWeb.EnsureUser($_.OwnerAlias)
				$u2 = $validatedSite.RootWeb.EnsureUser($_.SecondaryOwnerAlias)
				$validatedSite.RootWeb.CreateDefaultAssociatedGroups($u1, $u2, $_.Name)
				$validatedSite.RootWeb.Update();
			}
	    }
	}
	catch {
		Write-Host $_.Exception.Message -ForegroundColor:Red
    }
    finally {
    }