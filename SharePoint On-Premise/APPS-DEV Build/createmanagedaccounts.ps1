$accountpassword = 'pass@word1'
$accountname = 'contoso\sp_serviceapps'

$password = ConvertTo-SecureString  $accountpassword -AsPlainText -Force
$account = New-Object system.management.automation.pscredential $accountname, $password

New-SPManagedAccount -Credential $account


$accountname = 'contoso\sp_webapps'
$account = New-Object system.management.automation.pscredential $accountname, $password

New-SPManagedAccount -Credential $account
