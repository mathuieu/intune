<#
.SYNOPSIS
    Script de détection de la Faille Admin Local
.DESCRIPTION
    Permet de vérifier que l'appel aux fonctions de création d'un compte local 
    ont bien été supprimées dans le HTML autopilot
.EXAMPLE
    PS C:\> .\FailleAdminLocal-DETECTION.ps1
    lance le script
.OUTPUTS
    sortie 0 tout va bien sortie 1 la faille est présente
.NOTES
    créé le     : 09/01/2022
    mise à jour : 12/01/2022, 09:18:04  
#>
$date = Get-date -UFormat "%Y%m%d-%H%M%S"
# $logfilename = "$($env:ProgramData)\Intune\$env:Computername-$date-SCRIPT-FailleLocalAccount-DETECTION.log"
$logfilename = "$($env:ProgramData)\Intune\$env:Computername-SCRIPT-FailleLocalAccount-DETECTION.log"
Start-Transcript $logfilename
#######################
#Configure variables #
######################
# $Account = New-Object -TypeName System.Security.Principal.NTAccount -ArgumentList 'BUILTIN\Administrators';
$ItemList = Get-Item -Path C:\Windows\SystemApps\Microsoft.Windows.CloudExperienceHost_cw5n1h2txyewy\webapps\inclusiveOobe\view\oobelocalaccount-main.html

######################
# Détection
######################
Write-Host "Recherche de l'appel au fichier JS oobelocalaccount-page.js ..."
# $txtsuivi =""
$txtFinal = "ligne de la faille non trouvee"
foreach($line in Get-Content $itemlist)
{
    if($line -like '*/webapps/inclusiveOobe/js/oobelocalaccount-page.js*')
    {
        $Faille = $true
        # $txtsuivi += "`nligne trouvee et remplacee"
        $txtFinal = "ligne de la faille trouvee"
        Write-Host "$date - ligne de la faille trouvee"
    }
    else
    {
        # $txtsuivi += "`nligne non remplacee"
    }
}
Write-Host $txtFinal
Stop-Transcript
Write-Host $txtFinal
if($Faille){
    exit 1
}
else {
    exit 0
}