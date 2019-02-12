<# 
.SYNOPSIS
Test for empty or null values in a parameters file.

.DESCRIPTION
This script validates a paramter file to assure all values are present and well formed.

.PARAMETER file
Refers the file containing the parameters for a given script.

.EXAMPLE
From the PowerShell prompt run .\test_params.ps1 -file .\[enter the name of your parameters file].xml

.NOTES
14-07-08 Assembled by Ramona Maxwell for Gilead Sciences - Internal Use Only.

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
	[xml]$ScriptParams = Get-Content $file
	$newScriptParams = $ScriptParams.Accounts.Account
		if($newScriptParams -eq $null){
			Write-Warning "Managed Account parameters are not present in the parameters file."
			Write-Host "Ensure that the parameters file contains an <Account> node." -ForegroundColor:DarkMagenta
			return $false
		}		
	return $newScriptParams	
}

function paramTest
{
    Get-Parameters
	param(
    [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    $uname = $_.username
    )
    Write-Host 'Working' $uname
}

paramTest