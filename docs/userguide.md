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
Name of the file where all device connection strings will be exported. Device simulator requires connection strings of all devices in order to connect and send messages. Default value is `devices.txt`.

# Running the Device simulator app

Start a command line in `src/DeviceSimulator/` and run following command:
```
dotnet run ..\..\deployment\devices.txt
```
Please note that the first parameter is path to the file generated in deployment step.

Sample output:
```
Loading devices from ..\..\deployment\devices.txt... got 3 device(s)
Starting to send messages, use ENTER to stop...
tatodevice3 is starting...
tatodevice3 is sending '{"Value":0.729583379686616}'
tatodevice2 is starting...
tatodevice2 is sending '{"Value":0.8290573036433464}'
tatodevice1 is starting...
tatodevice1 is sending '{"Value":0.31187419002497296}'
tatodevice2 is sending '{"Value":0.6397306936046717}'
tatodevice3 is sending '{"Value":0.6556636051534039}'
tatodevice2 is sending '{"Value":0.7802519531828593}'
tatodevice1 is sending '{"Value":0.2003944521771718}'
```

You can check that the messages are received in the cloud by checking the overview page of your IoT hub resource.