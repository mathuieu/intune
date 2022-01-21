# Script de correction de la faille permettant de creer un compte local pendant Autopilot (pour Windows 10)

# https://call4cloud.nl/2022/01/the-return-of-the-autopilot-local-account-massacre/
Write-Host "debut du script : derniere modif 20/01/2022, 17:45:22"
# $date = Get-date -UFormat "%Y%m%d-%H%M%S"
# $logfilename = "$($env:ProgramData)\Intune\$env:Computername-$date-SCRIPT-FailleLocalAccount-CORRECTION.log"
$logfilename = "$($env:ProgramData)\Intune\$env:Computername-SCRIPT-FailleLocalAccount-CORRECTION.log"
Start-Transcript $logfilename -Append

##########################
# 1 # trying to get the file #
########################
$Account = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList 'builtin\Administrateurs';
try
{
	$Itemexists = test-path 'C:\Windows\SystemApps\*\webapps\inclusiveOobe\view\oobelocalaccount-main.html'
	$ItemList = Get-Item -Path C:\Windows\SystemApps\*\webapps\inclusiveOobe\view\oobelocalaccount-main.html
}
catch
{
	write-host "an error occurred (step 1)"
        exit 1
}

####################################
# 2 # change owner of the file         #
#####################################
if($Itemexists)
{ 

	$Acl = $null; 
    	$Acl = Get-Acl -Path $Itemlist.FullName; 
    	$Acl.SetOwner($Account); 
    	Set-Acl -Path $Itemlist.FullName -AclObject $Acl; 
}else{ 
	Write-Host  "File not found!"
        exit 1            
}

###########################################
# 3 # Change acl permissions                  #
###########################################
try
{
	$Acl = Get-Acl -Path $Itemlist.FullName; 
        $owner = $acl.owner
}
catch
{
	write-host "owner not found"
        exit 1
}

if ($owner -eq $account)      
{
   	$myPath = $itemlist
	$myAcl = Get-Acl "$myPath"
	$myAclEntry = "nt authority\system","FullControl","Allow"
	$myAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($myAclEntry)
	$myAcl.SetAccessRule($myAccessRule)
	$myAcl | Set-Acl "$MyPath"
	

	$myPath = $itemlist
	$myAcl = Get-Acl "$myPath"
	$myAclEntry = $account,"FullControl","Allow"
	$myAccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($myAclEntry)
	$myAcl.SetAccessRule($myAccessRule)
	$myAcl | Set-Acl "$MyPath"
	
}else{
       Write-Host "Permissions couldnt be changed"
       exit 1
}

##########################################################
# 4 # Remove the option to add a local account in oobe   #
#########################################################
Write-Host "Recherche et supression de l'appel au fichier JS oobelocalaccount-page.js ..."
$txtFinal = "ligne de la faille non trouvee"
$data = foreach($line in Get-Content $itemlist)
{
    if($line -like '*/webapps/inclusiveOobe/js/oobelocalaccount-page.js*')
    {
        Write-host "ligne trouvee et remplacee"
		$txtFinal = "ligne de la faille trouvee"}
		else
		{
			$line
			Write-host "ligne non remplacee"
		}
	}
	
	try
	{
		$data | Set-Content $itemlist -Force
		Write-Host "Fichier corrige"
		$txtFinal = "Fichier corrige"
	}
	catch
	{
		write-host "Le fichier n'a pas pu etre corrige"
		$txtFinal = "Le fichier n'a pas pu etre corrige"
}
Write-Host $txtFinal
Write-Host "Fin du script"
stop-Transcript
Write-Host $txtFinal