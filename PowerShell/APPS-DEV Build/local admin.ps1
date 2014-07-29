$de = [ADSI]"WinNT://$computer/$Group,group" 
$de.psbase.Invoke("Add",([ADSI]"WinNT://$domain/$user").path) 

$de = [ADSI]"WinNT://stockholm/administrators,group" 
$de.psbase.Invoke("Add",([ADSI]"WinNT://contoso/sp_install").path) 