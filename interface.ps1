##Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force
Connect-AzAccount 
. ./API/FunctionAPI.ps1
$Greetings = "Welcome to the Azure Management and Configuration Tool - 2021
This tool was created by Dorian Vallecillo Calderon(dorianivc1@gmail.com)"
Write-Host $Greetings
$ResourceGroupName="Functions-Training"

$SiteName='VenderNumeroRifaGabriel'

$Slot='Production'

SyncFunctionAppTriggers $ResourceGroupName $SiteName $Slot