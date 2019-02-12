# Create Managed Accounts
$password = ConvertTo-SecureString 'pass@word1' -AsPlainText -Force

# create sp_webapps
$account = New-Object system.management.automation.pscredential 'contoso\sp_webapps', $password 
New-SPManagedAccount $account

# create sp_serviceapps
$account = New-Object system.management.automation.pscredential 'contoso\sp_serviceapps', $password
New-SPManagedAccount $account

# Create the Service App Pool
New-SPServiceApplicationPool -Name "Default SharePoint Service App Pool" -Account contoso\sp_serviceapps
$apppool = Get-SPServiceApplicationPool "Default SharePoint Service App Pool"

# Set the default database server
$configdb = Get-SPDatabase | where type -EQ "Configuration Database"
$dbserver = $configdb.NormalizedDataSource

# Let's create some service apps

# Create new State Service
New-SPStateServiceApplication -Name "State Service"
Get-SPStateServiceApplication  | New-SPStateServiceApplicationProxy -defaultproxygroup
Get-SPStateServiceApplication | New-SPStateServiceDatabase -Name "State_Service_DB" -Databaseserver $dbserver
Get-spdatabase | where-object {$_.type -eq "Microsoft.Office.Server.Administration.StateDatabase"} | initialize-spstateservicedatabase

# Create new Usage Service
New-SPUsageApplication -Name "Usage and Health Data Collection"
$proxy = Get-SPServiceApplicationProxy | where {$_.TypeName -eq "Usage and Health Data Collection Proxy"}
$proxy.Provision()

# Create Managed Metadata Service app
New-SPMetadataServiceApplication -Name "Managed Metadata Service" -ApplicationPool $apppool -DatabaseServer $dbserver -DatabaseName "Metadata_Service_DB" 
New-SPMetadataServiceApplicationProxy -Name "Managed Metadata Service Proxy" -DefaultProxyGroup -ServiceApplication "Managed Metadata Service" 
Get-SPServiceInstance | where-object {$_.TypeName -eq "Managed Metadata Web Service"} | Start-SPServiceInstance 
# I can probably assign the variable and create the proxy in one step. Need to test
$saproxy = Get-SPServiceApplicationProxy | Where-Object { $_.typename -like "Managed*" } 
$saproxy.Properties.IsDefaultSiteCollectionTaxonomy = $true 
$saproxy.Update()

# Create Secure store
New-SPSecureStoreServiceApplication -ApplicationPool $apppool -AuditingEnabled:$false -DatabaseServer $dbserver -DatabaseName "Secure_Store_DB"-Name "Secure Store Service"
Get-SPServiceApplication | Where-Object {$_.typename -eq "Secure Store Service Application"} | New-SPSecureStoreServiceApplicationProxy -Name "Secure Store Service"
Get-SPServiceInstance | Where-Object { $_.TypeName -eq "Secure Store Service" } | Start-SPServiceInstance

# Create Business Connectivity Services 
New-SPBusinessDataCatalogServiceApplication -ApplicationPool $apppool -DatabaseName "Business_Connectivity_Services_DB" -DatabaseServer $dbserver -Name "Business Connectivity Services"
New-SPBusinessDataCatalogServiceApplicationProxy -Name "Business Connectivity Services Proxy" -ServiceApplication "Business Connectivity Services"
Get-SPServiceInstance | Where-Object { $_.TypeName -eq "Business Data Connectivity Service" } | Start-SPServiceInstance

# Create the Application Management Service
$appname = "App Management Service"
$dbname = "AppManagement_DB"

# Create the App Management service and start its service instance
$sa = New-SPAppManagementServiceApplication -ApplicationPool $apppool -Name $appname -DatabaseName $dbname 
New-SPAppManagementServiceApplicationProxy -ServiceApplication $sa -Name "$appname Proxy"
Get-SPServiceInstance | Where-Object { $_.typename -eq "App Management Service" } | Start-SPServiceInstance

# Create the Subscription Settings service and start its service instance
$sa = New-SPSubscriptionSettingsServiceApplication -ApplicationPool $appPool -Name "Subscription Settings Service" -DatabaseName "Subscription_Settings_Service_DB"
New-SPSubscriptionSettingsServiceApplicationProxy -ServiceApplication $sa
Get-SPServiceInstance | where{$_.TypeName -eq "Microsoft SharePoint Foundation Subscription Settings Service"} | Start-SPServiceInstance

# Configure your app domain and location
# assumes path of app.contoso-apps.com
# http://msdn.microsoft.com/en-us/library/fp179923(v=office.15).aspx 
Set-spappdomain -appdomain "contoso-apps.com"
Set-spappSiteSubscriptionName -Name "app"






























# Start a bunch of service instances
Get-SPServiceInstance | Where-Object { $_.typename -eq "Access Services" } | Start-SPServiceInstance
Get-SPServiceInstance | Where-Object { $_.typename -eq "Business Data Connectivity Service" } | Start-SPServiceInstance
Get-SPServiceInstance | Where-Object { $_.typename -eq "Excel Calculation Services" } | Start-SPServiceInstance
Get-SPServiceInstance | Where-Object { $_.typename -eq "Machine Translation Service" } | Start-SPServiceInstance
Get-SPServiceInstance | Where-Object { $_.typename -eq "Managed Metadata Web Service" } | Start-SPServiceInstance
Get-SPServiceInstance | Where-Object { $_.typename -eq "Secure Store Service" } | Start-SPServiceInstance
Get-SPServiceInstance | Where-Object { $_.typename -eq "Visio Graphics Service" } | Start-SPServiceInstance
