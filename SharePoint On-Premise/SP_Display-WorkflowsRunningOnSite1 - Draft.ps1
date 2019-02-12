<# 
.SYNOPSIS
Iterate through a site and find instances of a specific workflow that are currently running.
.DESCRIPTION
Based on script by Brian Jackett
.LINK
https://briantjackett.com/2010/07/12/powershell-script-to-find-instances-of-running-sharepoint-workflow/
#>

$workflowNameToCheck = Read-Host "Enter workflow name."
$url = Read-Host "Enter the URL"

$spSite = new-object Microsoft.SharePoint.SPSite($url)
$spWeb = $spSite.OpenWeb()
$workflowBase = $spweb.WorkflowTemplates | Where-Object {$_.Name -eq $workflowNameToCheck}
$spWeb.Dispose()

foreach($spWeb in $spSite.AllWebs)
{
    for($i = 0; $i -lt $spWeb.Lists.Count; $i++)
    {
        $spList = $spweb.Lists[$i]
        $assoc = $spList.WorkflowAssociations | Where-Object {$_.BaseId -eq $workflowBase.Id.ToString() -and $_.RunningInstances -gt 0}

	if($assoc -ne $null)
        {
	    foreach($item in $spList.Items)
            {
                if(($item.Workflows | Where-Object {$_.InternalState -eq "Running"}) -ne $null)
                {
                    write-output "$($spWeb.Name) | $($spList.Title) | $($item.Name)"
                }
            }
        }
    }
    $spWeb.Dispose()
}
$spSite.Dispose()