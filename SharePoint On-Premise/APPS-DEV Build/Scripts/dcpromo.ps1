# Add the AD Module
Import-module servermanager
Add-WindowsFeature AD-Domain-Services  

# Add the AD tools to the server
Add-windowsfeature rsat-adds -includeallsubfeature

# Create a new forest which creates a root domain
Install-addsforest -domainname contoso.com -safemodeadministratorpassword (convertto-securestring "pass@word1" -asplaintext -force) -domainmode win2008r2 -domainnetbiosname contoso -forestmode win2008r2
 
# Set the domain passwords to not expire
Set-ADDefaultDomainPasswordPolicy contoso.com -ComplexityEnabled $false -MaxPasswordAge "3650" -PasswordHistoryCount 0 -MinPasswordAge 0
 