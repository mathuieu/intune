# Script de correction de la faille permettant de créer un compte local pendant Autopilot (pour Windows 10)

# https://call4cloud.nl/2022/01/the-return-of-the-autopilot-local-account-massacre/
Write-Host "debut du script"
# $date = Get-date -UFormat "%Y%m%d-%H%M%S"
# $logfilename = "$($env:ProgramData)\Intune\$env:Computername-$date-SCRIPT-BlockLocalAccount.log"
$logfilename = "$($env:ProgramData)\Intune\$env:Computername-SCRIPT-BlockLocalAccount.log"
Start-Transcript $logfilename -Append

##########################
# 1 # trying to get the file #
########################
$Account = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList 'builtin\Administrators';
try {
	$Itemexists = test-path 'C:\Windows\SystemApps\*\webapps\inclusiveOobe\view\oobelocalaccount-main.html'
	$ItemList = Get-Item -Path C:\Windows\SystemApps\*\webapps\inclusiveOobe\view\oobelocalaccount-main.html
}
catch {
	write-host "an error occurred (step 1)"
	exit 1
}

####################################
# 2 # change owner of the file         #
#####################################
if ($Itemexists) { 
	$Acl = $null; 
	$Acl = Get-Acl -Path $Itemlist.FullName; 
	$Acl.SetOwner($Account); 
	Set-Acl -Path $Itemlist.FullName -AclObject $Acl; 
}
else { 
	Write-Host  "File not found!"
	exit 1            
}

###########################################
# 3 # Change acl permissions                  #
###########################################
try {
	$Acl = Get-Acl -Path $Itemlist.FullName; 
	$owner = $acl.owner
}
catch {
	write-host "owner not found"
	exit 1
}

if ($owner -eq $account) {
	$myPath = $itemlist
	$myAcl = Get-Acl "$myPath"
	$myAclEntry = "nt authority\system", "FullControl", "Allow"
	$myAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($myAclEntry)
	$myAcl.SetAccessRule($myAccessRule)
	$myAcl | Set-Acl "$MyPath"
	
	$myPath = $itemlist
	$myAcl = Get-Acl "$myPath"
	$myAclEntry = $account, "FullControl", "Allow"
	$myAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($myAclEntry)
	$myAcl.SetAccessRule($myAccessRule)
	$myAcl | Set-Acl "$MyPath"
}
else {
	Write-Host "Permissions couldnt be changed"
	exit 1
}

##########################################################
# 4 # Remove the option to add a local account in oobe   #
#########################################################
Write-Host "Recherche et supression de l'appel au fichier JS oobelocalaccount-page.js ..."
$txtsuivi = ""
$txtFinal = "ligne de la faille non trouvee"
$data = foreach ($line in Get-Content $itemlist) {
	if ($line -like '*/webapps/inclusiveOobe/js/oobelocalaccount-page.js*') {
		$txtsuivi += "`nligne trouvee et remplacee"
		$txtFinal = "ligne de la faille trouvee et remplacee"
	}
	else {
		$line
		$txtsuivi += "`nligne non remplacee"
	}
}
$data | Set-Content $itemlist -Force

Write-Host $txtsuivi
Write-Host "Fin du script"
stop-Transcript
Write-Host $txtFinal