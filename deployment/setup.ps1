param(
    [string]$SubscriptionId,
    [string]$ResourceGroupName = "tatoiotdemo",
    [string]$Location = "East US",
    [string]$IotHubName = "tatoiothub",
    [string]$DeviceIdPrefix = "tatodevice",
    [int]$DeviceCount = 3,
    [string]$StorageAccountName = "tatostorage",
    [string]$TsiEnvironmentName = "tatotsi",
    [string]$OutputFile = "devices.txt"
)

Import-Module Az
Import-Module Az.TimeSeriesInsights

function Main
{
    Write-Host "Connecting..."
    Connect-AzAccount

    if (-not [string]::IsNullOrEmpty($SubscriptionId))
    {
        Select-AzSubscription -SubscriptionId $SubscriptionId
    }

    Write-Host "Creating resource group $ResourceGroupName"
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Force

    Write-Host "Creating IoT Hub $IotHubName"
    CreateHub

    #Write-Host "Creating storage account $StorageAccountName"
    #CreateStorageAccount

    Write-Host "Creating $DeviceCount IoT devices..."
    CreateDevices

    if (-not [string]::IsNullOrEmpty($OutputFile))
    {
        Write-Host "Writing device connection strings to $OutputFile"
        Get-AzIotHubDeviceConnectionString -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName | ConvertTo-Json > $OutputFile
        Write-Host ""
    } 
    
    #Write-Host "Creating TSI environment $TsiEnvironmentName"
    #CreateTsiEnvironment

    Write-Host "Done."
}

function CreateTsiEnvironment
{
    Register-AzResourceProvider -ProviderNamespace Microsoft.TimeSeriesInsights

    $tsi = Get-AzTimeSeriesInsightsEnvironment -ResourceGroupName $ResourceGroupName -Name $TsiEnvironmentName -ErrorAction SilentlyContinue

    if ($null -eq $tsi)
    {
        $ks = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
        $accountKey  = $ks[0].Value | ConvertTo-SecureString -AsPlainText -Force
        
        $tsi = New-AzTimeSeriesInsightsEnvironment `
            -ResourceGroupName $ResourceGroupName `
            -Name $TsiEnvironmentName `
            -Location $Location `
            -Kind "Gen2" `
            -Sku "L1" `
            -StorageAccountName $StorageAccountName `
            -StorageAccountKey $accountKey `
            -WarmStoreDataRetentionTime (New-TimeSpan -Days 7)
            -TimeSeriesIdProperty @{name='iothub-connection-device-id';type='string'}
    }

    if ($null -eq $tsi)
    {
        throw "Cannot create TSI environment $TsiEnvironmentName"
    }    

    $tsi
}

function CreateStorageAccount
{
    $storage = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue

    if ($null -eq $storage)
    {
        $storage = New-AzStorageAccount `
            -ResourceGroupName $ResourceGroupName `
            -Name $StorageAccountName `
            -SkuName "Standard_LRS" `
            -Location $Location `
            -Kind "StorageV2" `
            -AllowSharedKeyAccess $true `
            -AllowBlobPublicAccess $true `
            -RoutingChoice "MicrosoftRouting" `
            -PublishMicrosoftEndpoint $true `
            -EnableHttpsTrafficOnly $true `
            -ErrorAction SilentlyContinue
    }

    if ($null -eq $storage)
    {
        throw "Cannot create storage account $StorageAccountName"
    }

    $storage
}

function CreateDevices
{
    for ($deviceIndex = 0; $deviceIndex -lt $DeviceCount; $deviceIndex++)
    {
        $deviceNumber = $deviceIndex + 1
        $deviceId = "$($deviceIdPrefix)$($deviceNumber)"
        Write-Host "Creating device $deviceId ($deviceNumber of $DeviceCount)"
        CreateDevice $deviceId
    }
}

function CreateDevice
{
    param([string]$deviceId)

    $device = Get-AzIotHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName -DeviceId $deviceId -ErrorAction SilentlyContinue

    if ($null -eq $device)
    {
        $device = Add-AzIotHubDevice -ResourceGroupName $ResourceGroupName -IotHubName $IotHubName -DeviceId $deviceId -ErrorAction Stop
    }

    $device
}

function CreateHub
{
    $hub = Get-AzIotHub -ResourceGroupName $ResourceGroupName -Name $IotHubName -ErrorAction SilentlyContinue

    if ($null -eq $hub)
    {
        $hub = New-AzIotHub `
            -ResourceGroupName $ResourceGroupName `
            -Name $IotHubName `
            -SkuName "F1" `
            -Units 1 `
            -Location $Location `
            -ErrorAction SilentlyContinue
    }

    if ($null -eq $hub)
    {
        throw "Cannot create IoT Hub $IotHubName"
    }

    $hub
}

Main