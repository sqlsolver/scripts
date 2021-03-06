 <# 
.SYNOPSIS
Enumerate user permissions within a site collection.

.DESCRIPTION
This script enumerates permissions within a site collection and outputs them to a .CSV file for import into 
Microsoft Excel or other analysis tools. 

.PARAMETER webURL
Refers the path to the site collection URL containing the sites that are being audited.

.EXAMPLE
From the PowerShell prompt run .\Permissions_Audit_1.ps1 -file .\[enter the name of your parameters file].xml

.NOTES
14-07-08 Assembled by Ramona Maxwell for Gilead Sciences - Internal Use Only.

.LINK
[add link to IT portal]
#>
 
 Param([string]$webURL)
 function EnumerateUserRolesPermissions ($webURL){
 $site = new-object Microsoft.SharePoint.SPSite($webURL)
 $web = $site.OpenWeb()
 $webUsers = $web.Users
 $groups = $web.sitegroups
	 foreach($webUser in $webUsers){
	 $Permissions = $web.Permissions
		 foreach($group in $groups)
		 {
			 foreach($Permission in $Permissions){
				 if($webUser.ID -eq $Permission.Member.ID){
					 foreach ($role in $webUser.Roles){
						 if ($role.Type -ne [Microsoft.SharePoint.SPRoleType]::None){
						 $webURL+“;“+$webUser.LoginName+“;“+$webUser.Name+“;"+$role.Type.ToString()+";"+$webUser.groups
						 }
					 }
				 }
				 if($group.ID -eq $Permission.Member.ID){
					 foreach ($role in $group.Roles){
						 if ($role.Type -ne [Microsoft.SharePoint.SPRoleType]::None){
							 foreach($user in $group.users){
							 $webURL+“;“+$user.LoginName+“;“+$user.Name+“;"+$role.Type.ToString()+";"+$group.name
							 }
						 }
					 }
				 }
			 }
		 }
	 }
 }
 function EnumerateSiteUsers (){
 [void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
 $farm = [Microsoft.SharePoint.Administration.SPFarm]::Local
	 foreach ($spService in $farm.Services) {
		 if (!($spService -is [Microsoft.SharePoint.Administration.SPWebService])) {
		 continue;
		 }
	 foreach ($webApp in $spService.WebApplications) {
	 	if ($webApp -is [Microsoft.SharePoint.Administration.SPAdministrationWebApplication]) { 
		continue }
	 $webAppUrl = $webApp.GetResponseUri('Default').AbsoluteUri
	 foreach ($site in $webApp.Sites) {
		 foreach ($web in $site.AllWebs) {
		 EnumerateUserRolesPermissions $web.url
		 }
	 }
	 }
	 }
 }
