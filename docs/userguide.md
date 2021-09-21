# Prerequisites

## Azure subscription

Demo solution uses Azure IoT hub. In order to use this demo you need to have a valid Azure subscription. You can get one free for limited time period.

[Create Your Azure Free Account Today | Microsoft Azure](https://azure.microsoft.com/en-us/free/)

## Powershell

Deployment script is written in powershell. Please make sure you have powershell 7 installed along with the Azure powershell module.

[Installing PowerShell on Windows - PowerShell | Microsoft Docs](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7.1)

[PowerShell Gallery | Az 6.3.0](https://www.powershellgallery.com/packages/Az/6.3.0)

## Device Simulator

Simple device simulator application is provided to send messages to Azure IoT hub. You will need .NET Core 3.1 in order to compile and run this application.

[Download .NET Core 3.1 (Linux, macOS, and Windows)](https://dotnet.microsoft.com/download/dotnet/3.1)

# How deploy and run

# Deployment of Azure resources

Start a powershell 7 session in `deployment/` and run following command:
```powershell
.\setup.ps1
```

## Syntax

```
.\setup.ps1
    [-SubscriptionId <subscription id>]
    [-ResourceGroupName <resource group name>]
    [-Location <location name>]
    [-IotHubName <name of the IoT hub>]
    [-DeviceCount <number of devices>]
    [-DeviceIdPrefix <device name prefix>]
    [-OutputFile <device connection string file>]
```

## Parameters

### -SubscriptionId
Subscription id you wish to use for this demo. If not provided the default subscription for the account will be used

### -ResourceGroupName
All Azure resources will be put in one resource group. Default name is `tatoiotdemo`.

### -Location
Azure region where the all resources will be created. Default is `East US`.

### -IotHubName
Name of the Azure IoT hub to be created. Default is `tatoiothub`.
IoT hub will be created in _Free_ tier thus incurring no cost.

### -DeviceCount
How many IoT devices should be created in the hub. Default values is `3`. Devices will be secured with a symmetric key.

### -DeviceIdPrefix
Devices will be names using _\<prefix\>\<number\>_ scheme, where prefix is customizable and number is a sequence starting at `1`. Default value for prefix is `tatodevice`.

### -OutputFile
Name of the file where Device simulator requires connection strings for all devices in order to connect and send messages. 