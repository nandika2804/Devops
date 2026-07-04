# Azure Subscription NSG Audit Tool
PowerShell automation tool that exports all Network Security Group (NSG) rules across an Azure subscription into a consolidated CSV report.

## Overview
This script discovers every NSG within a subscription and generates a centralized inventory of configured security rules.

The output is designed for:
- Security audits
- Compliance reviews
- Network documentation
- Cloud governance
- Migration planning

## Features
✅ Subscription-wide NSG discovery
✅ Consolidated security rule inventory
✅ Application Security Group (ASG) support
✅ Human-readable exports
✅ CSV reporting
✅ Read-only execution
✅ Azure PowerShell integration

## Requirements
```powershell
Install-Module Az
```

Required modules:
- Az.Accounts
- Az.Network

## Usage
```powershell
.\Export-AllAzureNSGRules.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

Custom output:
```powershell
.\Export-AllAzureNSGRules.ps1 `
    -SubscriptionId "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" `
    -OutPath ".\All-NSG-Rules.csv"
```

## Output Fields
- SubscriptionId
- ResourceGroup
- NSG
- RuleName
- Priority
- Direction
- Access
- Protocol
- Source
- SourcePort
- Destination
- DestinationPort

## Example Use Cases

### Security Governance
Review all NSG rules from a single report.

### Compliance Auditing
Provide evidence of configured firewall policies.

### Network Documentation
Generate an inventory of network security controls.

### Migration Readiness
Capture security configurations before cloud migrations.

## Technologies
- Azure
- PowerShell
- Az.Network
- Network Security Groups
- Application Security Groups

## Skills Demonstrated
- Azure Networking
- Cloud Security
- Security Governance
- Infrastructure Auditing
- PowerShell Automation
- Reporting & Documentation

## Disclaimer
This repository contains a generalized implementation intended for security reporting, governance reviews and operational visibility.
