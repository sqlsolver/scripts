# Add the snapin, in case it's not already installed 
Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue

$ap = New-SPAuthenticationProvider -UseWindowsIntegratedAuthentication -DisableKerberos 
New-SPWebApplication -Name "Upgrade" -ApplicationPool "Default SharePoint Web Apps" -Port 80 -Url http://upgrade.contoso.com -AuthenticationMethod NTLM -AuthenticationProvider $ap -DatabaseName "WSS_Content_Upgrade" 