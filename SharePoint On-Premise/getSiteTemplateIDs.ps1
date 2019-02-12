<# 
.SYNOPSIS
Identify site templates.

.DESCRIPTION
This script consists of a single function to list site templates and IDs.

.PARAMETER parameters
No parameters.

.EXAMPLE
From the PowerShell prompt run .\getSiteTemplateIDs.ps1

.NOTES
14-06-12 Assembled by Ramona Maxwell for Gilead Sciences - Internal Use Only.

.LINK
[add link to script library]
#>

	function Get-SPWebTemplateWithId 
{ 
     $templates = Get-SPWebTemplate | Sort-Object "Name" 
     $templates | ForEach-Object { 
     $templateValues = @{ 
	     "Title" = $_.Title 
	     "Name" = $_.Name 
	     "ID" = $_.ID 
	     "Custom" = $_.Custom 
	     "LocaleId" = $_.LocaleId 
      }

New-Object PSObject -Property $templateValues | Select @("Name","Title","LocaleId","Custom","ID") 
      } 
}

Get-SPWebTemplateWithId | Format-Table -AutoSize