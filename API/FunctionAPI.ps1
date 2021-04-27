$ErrorActionPreference = "Stop"

$WebAppApiVersion = "2018-02-01"

## WebHostingPlan operations

# Example call: ListAppServicePlans MyResourceGroup
Function ListAppServicePlans($ResourceGroupName)
{
    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/serverfarms -ApiVersion 2015-11-01
}

# Example call: GetAppServicePlan MyResourceGroup MyWHP
Function GetAppServicePlan($ResourceGroupName, $PlanName)
{
    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/serverfarms -Name $PlanName -ApiVersion $WebAppApiVersion
}

# Example call: CreateAppServicePlan MyResourceGroup "North Europe" MyHostingPlan
Function CreateAppServicePlan($ResourceGroupName, $Location, $PlanName, $SkuName = "F1", $SkuTier = "Free")
{
    $fullObject = @{
        location = $Location
        sku = @{
            name = $SkuName
            tier = $SkuTier
        }
    }

    New-AzResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/serverfarms -ResourceName $PlanName -IsFullObject -Properties $fullObject -ApiVersion $WebAppApiVersion -Force
}

# Example call: DeleteWebApp MyResourceGroup MySite
Function DeleteAppServicePlan($ResourceGroupName, $PlanName)
{
    Remove-AzResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/serverfarms -ResourceName $PlanName -ApiVersion $WebAppApiVersion -Force
}



## Site operations

# Example call: ListWebApps MyResourceGroup
Function ListWebApps($ResourceGroupName)
{
    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites -ApiVersion 2015-11-01
}

# Example call: GetWebApp MyResourceGroup MySite
Function GetWebApp($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -Name $ResourceName -ApiVersion $WebAppApiVersion
}

# Example call: CreateWebApp MyResourceGroup "North Europe" MySite DefaultServerFarm
Function CreateWebApp($ResourceGroupName, $Location, $SiteName, $PlanName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    New-AzResource -ResourceGroupName $ResourceGroupName -Location $Location -ResourceType $ResourceType -ResourceName $ResourceName -Properties @{ webHostingPlan = $PlanName } -ApiVersion $WebAppApiVersion -Force
}

# Example call: SetWebApp MyResourceGroup MySite $ConfigObject
Function SetWebApp($ResourceGroupName, $SiteName, $ConfigObject, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Set-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -ResourceName $ResourceName -Properties $ConfigObject -ApiVersion $WebAppApiVersion -Force
}

# Example call: DeleteWebApp MyResourceGroup MySite
Function DeleteWebApp($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Remove-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -ResourceName $ResourceName -ApiVersion $WebAppApiVersion -Force
}

# Example call: $planId = GetSiteAppServicePlanId MyResourceGroup MySite
Function GetSiteAppServicePlanId($ResourceGroupName, $SiteName, $Slot)
{
    $site = GetWebApp $ResourceGroupName $SiteName $Slot
    $site.Properties.serverFarmId
}

# Example call: StopWebApp MyResourceGroup MySite
Function StopWebApp($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -ResourceName $ResourceName -Action stop -ApiVersion $WebAppApiVersion -Force
}

# Example call: StopWebAppAndScm MyResourceGroup MySite
Function StopWebAppAndScm($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    $props = @{
        state = "stopped"
        scmSiteAlsoStopped = $true
    }

    Set-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -ResourceName $ResourceName -Properties $props -ApiVersion $WebAppApiVersion -Force
}

# Example call: StartWebApp MyResourceGroup MySite
Function StartWebApp($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -ResourceName $ResourceName -Action start -ApiVersion $WebAppApiVersion -Force
}

# Example call: GetWebAppInstances MyResourceGroup MySite
Function GetWebAppInstances($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/instances -Name $ResourceName -ApiVersion $WebAppApiVersion
}



## Site config operations

# Example call: GetWebAppConfig MyResourceGroup MySite
Function GetWebAppConfig($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/Config -Name $ResourceName/web -ApiVersion $WebAppApiVersion
}


# Example call: SetWebAppConfig MyResourceGroup MySite $ConfigObject
Function SetWebAppConfig($ResourceGroupName, $SiteName, $ConfigObject, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Set-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/Config -ResourceName $ResourceName/web -Properties $ConfigObject -ApiVersion $WebAppApiVersion -Force
}

# Example call: $phpVersion = GetPHPVersion MyResourceGroup MySite
Function GetPHPVersion($ResourceGroupName, $SiteName, $Slot)
{
    $config = GetWebAppConfig $ResourceGroupName $SiteName $Slot
    $config.Properties.phpVersion
}

# Example call: SetPHPVersion MyResourceGroup MySite "5.6"
Function SetPHPVersion($ResourceGroupName, $SiteName, $PHPVersion, $Slot)
{
    SetWebAppConfig $ResourceGroupName $SiteName @{ "phpVersion" = $PHPVersion } $Slot
}

# Example call: SetCorsUrls MyResourceGroup MySite @("http://foo.com", "http://bar.com")
Function SetCorsUrls($ResourceGroupName, $SiteName, $CorsUrls, $Slot)
{
    $cors = @{
        allowedOrigins = $CorsUrls
    }

    SetWebAppConfig $ResourceGroupName $SiteName @{ "cors" = $cors } $Slot
}


## App Settings

# Example call: GetWebAppAppSettings MyResourceGroup MySite
Function GetWebAppAppSettings($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    $res = Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/Config -ResourceName $ResourceName/appsettings -Action list -ApiVersion $WebAppApiVersion -Force
    $res.Properties
}

# Example call: SetWebAppAppSettings MyResourceGroup MySite @{ key1 = "val1"; key2 = "val2" }
Function SetWebAppAppSettings($ResourceGroupName, $SiteName, $AppSettingsObject, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    New-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/Config -ResourceName $ResourceName/appsettings -Properties $AppSettingsObject -ApiVersion $WebAppApiVersion -Force
}


## Connection Strings

# Example call: GetWebAppConnectionStrings MyResourceGroup MySite
Function GetWebAppConnectionStrings($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    $res = Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/Config -ResourceName $ResourceName/connectionstrings -Action list -ApiVersion $WebAppApiVersion -Force
    $res.Properties
}

# Example call: SetWebAppConnectionStrings MyResourceGroup MySite @{ conn1 = @{ Value = "Some connection string"; Type = 2  } }
Function SetWebAppConnectionStrings($ResourceGroupName, $SiteName, $ConnectionStringsObject, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    New-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/Config -ResourceName $ResourceName/connectionstrings -Properties $ConnectionStringsObject -ApiVersion $WebAppApiVersion -Force
}


## Slot settings

# Example call: GetSlotSettings MyResourceGroup MySite
Function GetSlotSettings($ResourceGroupName, $SiteName)
{
    $res = Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -Name $SiteName/slotConfigNames -ApiVersion $WebAppApiVersion
    $res.Properties
}

# Example call: SetSlotSettings MyResourceGroup MySite @{ appSettingNames = @("Setting1"); connectionStringNames = @("Conn1","Conn2") }
Function SetSlotSettings($ResourceGroupName, $SiteName, $SlotSettingsObject)
{
    New-AzResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/sites/Config -ResourceName $SiteName/slotConfigNames -Properties $SlotSettingsObject -ApiVersion $WebAppApiVersion -Force
}


## Log settings

Function GetWebAppLogSettings($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/config -Name $ResourceName/logs -ApiVersion $WebAppApiVersion
}

Function TurnOnApplicationLogs($ResourceGroupName, $SiteName, $Level, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    $props = @{
        applicationLogs = @{
            fileSystem = @{
                level = $Level
            }
        }
    }

    Set-AzResource -Properties $props -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/config -ResourceName $SiteName/logs -ApiVersion $WebAppApiVersion -Force
}


## Deployment related operations

# See also https://github.com/projectkudu/kudu/wiki/Deploying-a-WebJob-using-PowerShell-ARM-Cmdlets for related helpers

# Example call: DeployCloudHostedPackage MyResourceGroup "West US" MySite https://auxmktplceprod.blob.core.windows.net/packages/Bakery.zip
Function DeployCloudHostedPackage($ResourceGroupName, $SiteName, $packageUrl, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    New-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/Extensions -ResourceName $ResourceName/MSDeploy -Properties @{ "packageUri" = $packageUrl } -ApiVersion $WebAppApiVersion -Force
}

# Example call: GetPublishingProfile MyResourceGroup "MySite
Function GetPublishingProfile($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    $ParametersObject = @{
	    format = "xml"
    }

    Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -ResourceName $SiteName -Action publishxml -Parameters $ParametersObject -ApiVersion $WebAppApiVersion -Force
}

# Example call: GetPublishingCredentials MyResourceGroup "MySite
Function GetPublishingCredentials($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    $resource = Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/config -ResourceName $SiteName/publishingcredentials -Action list -ApiVersion 2015-08-01 -Force
    $resource.Properties
}

# Deploy from an external git repo
Function HookupExternalGitRepo($ResourceGroupName, $SiteName, $repoUrl, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    $props = @{
        RepoUrl = $repoUrl
        Branch = "master"
        IsManualIntegration = $true
    }

    New-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/SourceControls -ResourceName $ResourceName/Web -Properties $props -ApiVersion $WebAppApiVersion -Force
}

# Get the list of git deployments
Function GetGitDeployments($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/Deployments -Name $ResourceName -ApiVersion $WebAppApiVersion
}


## WebJobs operations

# Example call: ListTriggeredWebJob MyResourceGroup MySite
Function ListTriggeredWebJob($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    # Use -ResourceId because Get-AzureRmResource doesn't support listing collections at the Resource Provider level
    $Subscription = (Get-AzContext).Subscription.SubscriptionId
    Get-AzResource -ResourceId /subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$SiteName/TriggeredWebJobs -ApiVersion 2015-08-01
}

# Example call: GetTriggeredWebJob MyResourceGroup MySite MyWebJob
Function GetTriggeredWebJob($ResourceGroupName, $SiteName, $WebJobName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/TriggeredWebJobs -Name $ResourceName/$WebJobName -ApiVersion $WebAppApiVersion
}

# Example call: GetTriggeredWebJobHistory MyResourceGroup MySite MyWebJob
Function GetTriggeredWebJobHistory($ResourceGroupName, $SiteName, $WebJobName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    # Use -ResourceId because Get-AzureRmResource doesn't support listing collections at the Resource Provider level
    $Subscription = (Get-AzContext).Subscription.SubscriptionId
    Get-AzResource -ResourceId /subscriptions/$Subscription/resourceGroups/$ResourceGroupName/providers/Microsoft.Web/sites/$SiteName/TriggeredWebJobs/$WebJobName/history -ApiVersion 2015-08-01
}

# Example call: RunTriggeredWebJob MyResourceGroup MySite MyWebJob
Function RunTriggeredWebJob($ResourceGroupName, $SiteName, $WebJobName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/TriggeredWebJobs -ResourceName $SiteName/$WebJobName -Action run -ApiVersion $WebAppApiVersion -Force
}

Function StartContinuousWebJob($ResourceGroupName, $SiteName, $WebJobName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/ContinuousWebJobs -ResourceName $SiteName/$WebJobName -Action start -ApiVersion $WebAppApiVersion -Force
}

Function StopContinuousWebJob($ResourceGroupName, $SiteName, $WebJobName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/ContinuousWebJobs -ResourceName $SiteName/$WebJobName -Action stop -ApiVersion $WebAppApiVersion -Force
}


## Functions operations

# Create a function app with app settings all in one create operation
# Example call: CreateFunctionApp MyResourceGroup "West Central US" MyFunctionApp "full conn string..." "~1"
Function CreateFunctionApp($ResourceGroupName, $Location, $SiteName, $StorageConnectionString, $FuncVersion)
{
    $functionTemplate = @{
        ResourceGroupName = $ResourceGroupName
        ResourceName = $SiteName
        ResourceType = "Microsoft.Web/sites"
        Kind = "functionapp"
        Properties = @{
            siteConfig = @{
                appSettings = @(
                    @{
                        name = "AzureWebJobsStorage"
                        value = $StorageConnectionString
                    }
                    @{
                        name = "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING"
                        value = $StorageConnectionString
                    }
                    @{
                        name = "FUNCTIONS_EXTENSION_VERSION"
                        value = $FuncVersion
                    }
                )
            }
        }
        Location = $Location
        Force = $true
    }

    New-AzResource @functionTemplate
}


Function SyncFunctionAppTriggers($ResourceGroupName, $SiteName, $Slot)
{ 
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName 
    $ResourceGroupName=$ResourceGroupName.ToString()
    Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -ResourceName $SiteName  -Action syncfunctiontriggers -ApiVersion $WebAppApiVersion -Force
}

Function DeployHttpTriggerFunction($ResourceGroupName, $SiteName, $FunctionName, $CodeFile, $TestData, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    $FileContent = "$(Get-Content -Path $CodeFile -Raw)"

    $props = @{
        config = @{
            bindings = @(
                @{
                    type = "httpTrigger"
                    direction = "in"
                    webHookType = ""
                    name = "req"
                }
                @{
                    type = "http"
                    direction = "out"
                    name = "res"
                }
            )
        }
        files = @{
            "index.js" = $FileContent
        }
        test_data = $TestData
    }

    New-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/functions -ResourceName $SiteName/$FunctionName -Properties $props -ApiVersion 2015-08-01 -Force
}

Function GetFunctionInvokeUrl($ResourceGroupName, $SiteName, $FunctionName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/Functions -ResourceName $SiteName/$FunctionName -Action listsecrets -ApiVersion $WebAppApiVersion -Force
}




## Site extension operations

# Example call: ListWebAppSiteExtensions MyResourceGroup MySite
Function ListWebAppSiteExtensions($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/siteextensions -Name $ResourceName -ApiVersion $WebAppApiVersion
}

# Example call: InstallSiteExtension MyResourceGroup MySite filecounter
Function InstallSiteExtension($ResourceGroupName, $SiteName, $Name, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    New-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/siteextensions -ResourceName $ResourceName/$Name -Properties @{} -ApiVersion $WebAppApiVersion -Force
}

# Example call: UninstallSiteExtension MyResourceGroup MySite filecounter
Function UninstallSiteExtension($ResourceGroupName, $SiteName, $Name, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Remove-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/siteextensions -ResourceName $ResourceName/$Name -ApiVersion $WebAppApiVersion -Force
}


## Certificate operations

# Example call: UploadCert MyResourceGroup "North Europe" foo.pfx "MyPassword!" MyTestCert
Function UploadCert($ResourceGroupName, $Location, $PfxPath, $PfxPassword, $CertName)
{
    # Read the raw bytes of the pfx file
    $pfxBytes = get-content $PfxPath -Encoding Byte

    $props = @{
        PfxBlob = [System.Convert]::ToBase64String($pfxBytes)
        Password = $PfxPassword
    }

    New-AzResource -Location $Location -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/certificates -ResourceName $CertName -Properties $props -ApiVersion $WebAppApiVersion -Force
}

# Example call: DeleteCert MyResourceGroup MyCert
Function DeleteCert($ResourceGroupName, $CertName)
{
    Remove-AzResource -ResourceGroupName $ResourceGroupName -ResourceType Microsoft.Web/certificates -ResourceName $CertName -ApiVersion $WebAppApiVersion -Force
}


## Premium Add-Ons

Function GetWebAppAddons($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Get-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/premieraddons -Name $ResourceName -ApiVersion $WebAppApiVersion
}

Function AddZrayAddon($ResourceGroupName, $Location, $SiteName, $Name, $PlanName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    $plan = @{
        name = $PlanName
        publisher = "zend-technologies"
        product = "z-ray"
    }

    New-AzResource -ResourceGroupName $ResourceGroupName -Location $Location -ResourceType $ResourceType/premieraddons -ResourceName $ResourceName/$Name -Properties @{} -Plan $plan -ApiVersion $WebAppApiVersion -Force
}

Function RemoveWebAppAddon($ResourceGroupName, $SiteName, $Name, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Remove-AzResource -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType/premieraddons -ResourceName $ResourceName/$Name -ApiVersion $WebAppApiVersion -Force
}

## Sync repository

Function SyncWebApp($ResourceGroupName, $SiteName, $Slot)
{
    $ResourceType,$ResourceName = GetResourceTypeAndName $SiteName $Slot

    Invoke-AzResourceAction -ResourceGroupName $ResourceGroupName -ResourceType $ResourceType -ResourceName $ResourceName  -Action sync -ApiVersion $WebAppApiVersion -Force
}

## Deployment creds (user level, NOT site level!)

Function SetDeploymentCredentials($UserName, $Password)
{
    $props = @{
        publishingUserName = $UserName
        publishingPassword = $Password
    }

    Set-AzResource -Properties $props -ResourceId /providers/Microsoft.Web/publishingUsers/web -ApiVersion 2015-08-01 -Force
}


## Helper method

# This deals with the type/name differences in the slot vs no-slot cases
Function GetResourceTypeAndName($SiteName, $Slot)
{
    $ResourceType = "Microsoft.Web/sites"
    $ResourceName = $SiteName
    if ($Slot) {
        $ResourceType = "$($ResourceType)/slots"
        $ResourceName = "$($ResourceName)/$($Slot)"
    }

    $ResourceType,$ResourceName
}


