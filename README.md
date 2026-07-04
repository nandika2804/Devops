# Azure VM Effective NSG Reporting Tool
PowerShell automation tool that exports effective inbound and outbound network access rules for Azure Virtual Machines.

The script analyzes Azure Effective Network Security Groups (NSGs) and produces an Excel report showing all allowed and denied ports after Azure merges subnet and NIC level NSG rules.



## Features
- Effective NSG rule analysis
- Multi-NIC support
- Excel report generation
- Automatic Network Watcher validation
- Port range expansion
- Inbound and outbound traffic visibility
- Allow and Deny rule reporting



## Output
The generated report contains:
- VM Name
- Network Security Group
- Port
- Direction
- Protocol
- Access Action



## Use Cases

### Security Reviews
Identify open ports and validate network exposure.

### Compliance Audits
Generate evidence of effective network access.

### Troubleshooting
Analyze allowed and denied traffic paths.

### Operational Documentation
Maintain visibility into production NSG configurations.

## Technologies
- Azure Virtual Machines
- Azure Network Security Groups
- Azure Network Watcher
- PowerShell
- Az.Network
- ImportExcel



## Example Output
| VM Name | NSG | Port | Inbound | Outbound | Protocol | Allow |
|----------|----------|----------|----------|----------|----------|----------|
| WEB01 | NSG-WEB | 443 | Yes | No | TCP | Allow |
| WEB01 | NSG-WEB | 3389 | Yes | No | TCP | Deny |



## Disclaimer
All environment-specific information has been removed. This project is intended for operational reporting, security reviews, and troubleshooting demonstrations.
