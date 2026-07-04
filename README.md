# Azure NSG Rule Export Tool
PowerShell automation script that exports all custom Network Security Group (NSG) rules from a specified Azure NSG into a structured CSV report.



## Overview
This tool retrieves security rules from an Azure NSG and converts Azure-specific objects such as:
- Address Prefix Lists
- Port Range Collections
- Application Security Groups (ASG)
into human-readable values suitable for reporting, documentation, and compliance reviews.



## Features
✅ Export all NSG rules
✅ Clean CSV reporting
✅ Application Security Group (ASG) support
✅ Multi-address support
✅ Multi-port support
✅ Read-only operation
✅ Azure PowerShell integration



## Requirements

PowerShell Modules:
```powershell
Az.Accounts
Az.Network
```



Install:
```powershell
Install-Module Az
```



## Parameters

| Parameter | Description |

|------------|-------------|
| SubscriptionId | Azure subscription ID |
| ResourceGroupName | Resource Group containing the NSG |
| NSGName | Network Security Group name |
| OutPath | Output CSV file |



## Usage

```powershell
.\Export-AzureNSGRules.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -ResourceGroupName "RG-Network" `
    -NSGName "NSG-Web" `
    -OutPath ".\NSG-Rules.csv"
```

## Sample Output
```text
SubscriptionId
ResourceGroup
NSG
RuleName
Priority
Direction
Access
Protocol
Source
SourcePort
Destination
DestinationPort
```

Example:
```text
Prod-Subscription
RG-Network
NSG-Web
Allow-HTTPS
100
Inbound
Allow
Tcp
Internet
*
10.0.1.10
443
```



## Use Cases

### Security Auditing
Review allowed and denied traffic rules.

### Compliance Reviews
Generate evidence of configured network controls.

### Documentation
Export current NSG configurations into a shareable format.

### Troubleshooting
Quickly inspect active network security rules.

## Technologies
- Azure
- Azure Networking
- Network Security Groups
- PowerShell
- Az.Network

## Disclaimer
This project contains a generalized implementation intended for automation, reporting, and troubleshooting purposes. All environment-specific information has been removed.
