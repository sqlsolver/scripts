# This script writes all of your farm's incoming URLs to a server's local hosts file
# and points them to the server itself
# It also disables the LSA loopback check
# Check out http://toddklindt.com/loopback for more information
# Copyright Todd Klindt 2011
# Originall published to http://www.toddklindt.com/blog

#Make backup copy of the Hosts file with today's date
$hostsfile = 'C:\Windows\System32\drivers\etc\hosts'
$date = Get-Date -UFormat "%y%m%d%H%M%S"
$filecopy = $hostsfile + '.' + $date + '.copy'
Copy-Item $hostsfile -Destination $filecopy

# Get a list of the AAMs and weed out the duplicates
$hosts = Get-SPAlternateURL | ForEach-Object {$_.incomingurl.replace("https://","").replace("http://","")} | where-Object { $_.tostring() -notlike "*:*" } | Select-Object -Unique
 
# Get the contents of the Hosts file
$file = Get-Content $hostsfile
$file = $file | Out-String

# write the AAMs to the hosts file, unless they already exist.
$hosts | ForEach-Object { if ($file.contains($_)) 
{Write-Host "Entry for $_ already exists. Skipping"} else 
{Write-host "Adding entry for $_" ; add-content -path $hostsfile -value "127.0.0.1 `t $_ " }}

# Disable the loopback check, since everything we just did will fail if it's enabled
New-ItemProperty HKLM:\System\CurrentControlSet\Control\Lsa -Name "DisableLoopbackCheck" -Value "1" -PropertyType dword
