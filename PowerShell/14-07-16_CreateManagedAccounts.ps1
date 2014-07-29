 <# 
.SYNOPSIS
Create and apply SharePoint 2013 Managed Accounts.

.DESCRIPTION
This script creates Managed Accounts for SharePoint services and assigns them. 

.PARAMETER file
Refers the file containing the account creation and SharePoint farm service parameters.

.EXAMPLE
From the PowerShell prompt run .\14-07-16_CreateManagedAccounts.ps1 -file .\[enter the name of your parameters file].xml

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
	
try {
	Get-Parameters | ForEach-Object {
	$newAccountConfig = $_
	Write-Host "$newAccountConfig.username and $newAccountConfig.password" #This line should print XML reference to screen.
	$secPassword = ConvertTo-SecureString($newAccountConfig.password) -asplaintext -force
	$cred = New-Object System.Management.Automation.PSCredential ($newAccountConfig.username, $secPassword)
	$newAccount = New-SPManagedAccount -credential $cred
	$newAccountSettings = Set-SPManagedAccount -Identity $newAccountConfig.username -UseExistingPassword -ExistingPassword $secPassword	
	Write-Host "Managed accounts have been created using existing passwords from Active Directory."
	}
}
catch  [System.Management.Automation.PSArgumentException]{
	Write-Host $_.Exception.Message -ForegroundColor:Red | Format-Table -AutoSize
	}
finally {
Write-Host "Script execution has completed. "
}