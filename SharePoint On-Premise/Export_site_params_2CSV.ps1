<# 
.SYNOPSIS
Collects user-supplied site creation values from a list.

.DESCRIPTION
Collects user-supplied site creation values from a list and exports them to a .CSV parameters file.

.PARAMETER Parameters
A required parameter, an XML file containing parameter values.

.EXAMPLE
.\CreateMultipleHNSC.ps1

.NOTES
2013-04-10 Assembled by Ramona Maxwell, MCPD SharePoint 2010 - Ramona@SharePointSolver.com @sqlsolver

.LINK
http://www.SharePointSolver.com
#>


#Creates the csv file
$file = New-Item "C:\Temp\MediForce-Invoice.csv" -type File

#sets the header column
Add-Content -Path $file -Value "Unique Job Ref,Service Date,PO Number,Account Number,Customer Name,Invoice Description,Unit Charge,Quantity,Invoice Amount"

$MyWeb = Get-SPWeb "http://companyweb"
$MyList = $MyWeb.Lists["Allocation A&E & Events"]

#Creates a query to pull back only items where Ready for Invoice = 1 and Invoiced = 0
###  You'll have to enter the internal name of your fields and not the display name of the column for each of the fields or this will not work##
$spQuery = New-Object Microsoft.SharePoint.SPQuery
$spQuery.query = '<Where><And><Eq><FieldRef Name="Ready_x0020_for_x0020_Invoice" /><Value Type="Boolean">1</Value></Eq><Eq><FieldRef Name="Invoiced" /><Value Type="Boolean">0</Value></Eq></And></Where>'

#grabs only the items that meet the query rules
$items = $Mylist.getItems($spQuery)

foreach($item in $items){

#replacing the "float;#" that sharepoint prepends to the decimal value
 $Invoice = $item["Invoice Amount"] -replace "float;#",""
 $Invoice ="{0:C2}" -f $Invoice                  
 $Quantity = $item["Quantity"]
 $UnitCharge = $item["Unit Charge"]
 $Callsign = $item["Title"] 
 $Customer = $item["Customer"]
 $Customer = $Customer.substring($Customer.indexOf("#") +1)
 $AccountNumber = $item["Account Number"]
 $AccountNumber = $AccountNumber.substring($AccountNumber.indexOf("#") +1)
 $SiteNumber = $item["SRCL Site No"]
 $PONumber = $item["PO Number"]
 $Date = $item["Start Date"]
 $UniqueJob = $item["ID"]
 
 #export the data
 Add-Content -path $file -Value "$uniqueJob,$date,$PONumber,$AccountNumber,$SiteNumber,$Customer,$callsign,$UnitCharge,$Quantity,$invoice"

 #set the field 'invoiced' to true  
 $item["Invoiced"] = $true;
 #commits the changes
 $item.update()
 
}