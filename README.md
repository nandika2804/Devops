# Azure NSG Rule Automation
Python-based automation tool for bulk creation and management of Azure Network Security Group (NSG) rules using Excel spreadsheets.



## Overview
This tool reads NSG rule definitions from an Excel workbook, validates the configuration, and applies the required changes using Azure CLI.

The script supports both rule creation and updates, making it useful for large-scale network security management in Azure environments.



## Features
✅ Bulk NSG rule deployment
✅ Excel-driven configuration
✅ Create and update support
✅ What-If (dry-run) mode
✅ CSV activity logging
✅ Multi-subscription support
✅ Automatic validation
✅ Optional NSG creation



## Input Format
Required columns:
- NSGName
- RuleName
- Description
- Direction
- Priority
- Protocol
- SourceAddress
- DestinationAddress
- SourcePort
- DestinationPort
- Subscription
- ResourceGroup
- Action



## Example Usage
```bash
python3 apply_nsg_rules.py \
  --file Rules.xlsx
```



Validate only:
```bash
python3 apply_nsg_rules.py \
  --file Rules.xlsx \
  --what-if
```

Enable logging:
```bash
python3 apply_nsg_rules.py \
  --file Rules.xlsx \
  --log-file deployment_results.csv
```

Create missing NSGs:
```bash
python3 apply_nsg_rules.py \
  --file Rules.xlsx \
  --create-missing-nsgs
```



## Use Cases

### Security Rule Standardization
Apply consistent security policies across multiple environments.

### Infrastructure Migration
Recreate NSG configurations during cloud migrations.

### Operational Automation
Reduce manual Azure Portal administration.

### Compliance Auditing
Track and log all network security rule changes.

## Technologies
- Python
- Azure CLI
- Azure Networking
- Azure NSG
- OpenPyXL
- Cloud Shell

## Skills Demonstrated
- Azure Networking
- Infrastructure Automation
- Python Development
- Input Validation
- Error Handling
- Operational Tooling
- Cloud Security

## Disclaimer
This repository contains a generalized implementation intended for automation demonstrations and operational use cases. Environment-specific information has been removed.
