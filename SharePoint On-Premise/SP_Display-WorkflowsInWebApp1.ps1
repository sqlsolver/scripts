<# 
.SYNOPSIS
Iterate through a web application and find all workflows.
.LINK
http://www.sharepointdiary.com/2013/07/sharepoint-workflows-inventory-report.html
#>

$WebAppURL = Read-Host "Enter the web application URL."
Function global:Get-SPWebApplication($WebAppURL)
{
 return [Microsoft.SharePoint.Administration.SPWebApplication]::Lookup($WebAppURL)
}
 
#Function to Get the workflow inventory for the entire web application
function Get-WorkflowInventory([string] $WebAppURL)
{
    #Get the Web Application URL
    $WebApp = Get-SPWebApplication $WebAppURL 
  
    #Iterate through each site collection
    foreach ($Site in $WebApp.Sites)
          {                              
                #Loop through each site     
                foreach ($Web in $Site.AllWebs)
                   {
                    #Loop through each list
                    foreach ($List in $Web.Lists)
                      {
                         # Leave hidden Lists and Libraries
                         if($List.Hidden -eq $false)
                         {
                            foreach ($WorkflowAssociation in $List.WorkflowAssociations)
                            {
                                #Leave the "Previous Versions"
                                if($WorkflowAssociation.Name.Contains("Previous Version") -eq $false)
                                    {
                                       $data = @{
                                        "Site" = $Site.Rootweb.Title
                                        "Web" = $Web.Title
                                        "Web URL" = $Web.Url
                                        "List Name" = $List.Title
                                        "List URL" =  $Web.Url+"/"+$List.RootFolder.Url
                                        "Workflow Name" = $WorkflowAssociation.Name
                                        "Running Instances" = $WorkflowAssociation.RunningInstances
                                        }
                                         
                                        #Create a object
                                        New-Object PSObject -Property $data
                                    }
                              }
                          }                    
                    }
                     $Web.Dispose()                  
                }
                $Site.Dispose()                   
    }
} 
 
#call the function
Get-WorkflowInventory | Export-Csv -NoTypeInformation -Path D:\Reports\WorkflowInventory.csv
 
write-host "Workflows Inventory report has been generated successfully!"