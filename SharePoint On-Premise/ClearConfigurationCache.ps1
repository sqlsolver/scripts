 <# 
.SYNOPSIS
Clear SharePoint's configuration cache.

.DESCRIPTION
This script clears SharePoint's configuration cache. 

.PARAMETER
There are no parameters.

.EXAMPLE
From the PowerShell prompt run .\ClearConfigurationCache.ps1

.NOTES
Authored by Thomas Bernhard, SharePoint PFE

.LINK
http://blogs.technet.com/b/sp/archive/2013/05/29/clear-sharepoint-config-cache-with-powershell.aspx
#>

Stop-Service SPTimerV4
$folders = Get-ChildItem C:\ProgramData\Microsoft\SharePoint\Config 
foreach ($folder in $folders)
    {
    $items = Get-ChildItem $folder.FullName -Recurse
    foreach ($item in $items)
        {
            if ($item.Name.ToLower() -eq "cache.ini")
                {
                    $cachefolder = $folder.FullName
                }
                
        }
    }
$cachefolderitems = Get-ChildItem $cachefolder -Recurse
    foreach ($cachefolderitem in $cachefolderitems)
        {
            if ($cachefolderitem -like "*.xml")
                {
                   $cachefolderitem.Delete()
                }
        
        }
        
$a = Get-Content  $cachefolder\cache.ini
$a  = 1
Set-Content $a -Path $cachefolder\cache.ini

read-host "Do this on all your SharePoint Servers - and THEN press ENTER" 
start-Service SPTimerV4