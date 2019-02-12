# This script can be used to build aa sharePoint 20110 or 2013 farm
# Written by Todd Klindt v1.0
# http://www.toddklindt.com/createfarm

# Add the SharePoint Snapin, in case PowerShell wasn't started with the Management Shell
Add-PSSnapin microsoft.sharepoint.powershell -ErrorAction SilentlyContinue

# Verify that PowerShell is running as an Admin
if ( -not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{ 
    Write-Output "This PowerShell prompt is not elevated"
    write-output "Please start PowerShell with the Admin token and try again"
    return
}

# Everything looks good. Let's build us a SharePoint farm

$domain = (Get-ChildItem env:userdomain).value
$tempfarmaccount = $domain.ToString() + '\sp_farm'
$tempsqlserver = (Get-ChildItem env:computername).value

$farmaccountname = Read-Host -Prompt "Enter Farm Account Name. Press Enter for $tempfarmaccount"
If ($farmaccountname -eq "") {$farmaccountname = $tempfarmaccount}
$farmaccountpassword = Read-Host -Prompt "Enter Farm Account Password. Press Enter for pass@word1"
If ($farmaccountpassword -eq "") {$farmaccountpassword = 'pass@word1'}
$farmpassphrase = Read-Host -Prompt "Enter Farm Passphrase. Press Enter for pass@word1"
If ($farmpassphrase -eq "") {$farmpassphrase = 'pass@word1'}
$sqlserver = Read-Host -Prompt "Enter SQL Instance name. Press Enter for $tempsqlserver"
If ($sqlserver -eq "") {$sqlserver = $tempsqlserver}

$password = ConvertTo-SecureString  $farmaccountpassword -AsPlainText -Force
$farmaccount = New-Object system.management.automation.pscredential $farmaccountname, $password

Write-Host "Using that information to build your SharePoint Farm"

New-SPConfigurationDatabase -DatabaseName SharePoint_Config -DatabaseServer $sqlserver -AdministrationContentDatabaseName SharePoint_Admin_Content -Passphrase (convertto-securestring $farmpassphrase -AsPlainText -Force) -FarmCredentials $farmaccount

Write-Host "Config database built, now configuring local machine."

Install-SPHelpCollection -All
Initialize-SPResourceSecurity
Install-SPService
Install-SPFeature -AllExistingFeatures

Write-host "Creating Central Admin on port 10260"

New-SPCentralAdministration -Port 10260 -WindowsAuthProvider "NTLM"
Install-SPApplicationContent

