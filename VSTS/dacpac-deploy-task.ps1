<# 
.SYNOPSIS
VSTS PowerShell release task to deploy DACPAC to on-premise SQL Server using Private Agent and impersonation.

.DESCRIPTION
The SQL Database Deployment task in VSTS doesn't offer an option to run under a specific set of user credentials. A request was made by someone to add this functionality for Azure deployment, that is not yet implemented.

.PARAMETER dacpac
Location of your DACPAC

.PARAMETER publishProfile
Location of the Publish profile for your DACPAC deployment.

.NOTES
18-01-08 Assembled by Ramona Maxwell - Microsoft Public License (Ms-PL) USE AT YOUR OWN RISK, you assume all 
liability for your use of any code herein.

.LINK
https://ramonamaxwell.com
https://magenic.com
#>

#parameters
Param(
  [string]$user
)

#Housekeeping
	$ErrorActionPreference = "Continue"
	$dateStamp = Get-Date -Format "yyyy-MM-dd-hhmm"
	$transcript = ".\" + $dateStamp + "_" + $MyInvocation.MyCommand.Name.Replace(".ps1", "") + ".log"
	$outputFile = ".\" + $dateStamp + "_" + $MyInvocation.MyCommand.Name.Replace(".ps1", "") + "_run.txt"
	Start-Transcript -Path $transcript

#switch user context
$user = 'cfgo.com\svc-devbpmvsts'
$pass = ConvertTo-SecureString -String 'ckpRA*6vab5hUn2' -Force -AsPlainText
$Cred = New-Object System.Management.Automation.PSCredential($user,$pass)

#publish db	
function dbPublish() {
	Write-Host "==============================================================================="
	Write-Host "==                     Publish Database                                      =="
	Write-Host "==============================================================================="
	$command = "C:\Windows\SysWOW64\Microsoft.Data.Tools.Msbuild\lib\net46\sqlpackage.exe /Action:Publish /Sourcefile:'C:\buildagent\_work\14\a\GO_DEV_T3\bin\Debug\GO_DEV_T3.dacpac' /Profile:'C:\buildagent\_work\14\a\GO_DEV_T3\bin\Debug\GO_DEV_T3publish.xml'"
	Invoke-Expression $command | Write-Output
	}
Start-Job -Credential $Cred -ScriptBlock ${function:dbPublish} 
Stop-Transcript
