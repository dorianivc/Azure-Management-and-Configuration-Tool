. ./API/FunctionAPI.ps1
$Greetings = "Welcome to the Azure Management and Configuration Tool - 2021
This tool was created by Dorian Vallecillo Calderon(dorianivc1@gmail.com)




"
$Porpuse="This tool was designed to perfom Management and Configuration to your Azure Resources"
$Menu="
Please select one of the following options:
0. Install PowerShell Missing Modules
1. Login Azure Account
1. Syncronizate Function Apps Triggers
2. Create App Service Plan
3. Delete App Service Plan
"
Write-Host $Greetings
Write-Host $Porpuse

do{
    Write-Host $Menu

}while ($option -eq -1) {

    $option= Read-Host "Please enter the number of the desired option: "
    switch ($option){
        
        0 {Install-Module -Name Az -Scope CurrentUser -Repository PSGallery -Force 
            break}
        2{Connect-AzAccount
            break }
    default {$option=-1
        Write-Error "Ninguna Opcion Selecionada"
        Start-Sleep -s 15
        Clear-Host
        Write-Host $Greetings
        Write-Host $Porpuse
        }
    }
    
}



