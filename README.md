# Azure VM CPU Reporting Tool
PowerShell automation script that generates CPU utilization reports for Azure Virtual Machines across multiple subscriptions.
 
## Overview 
This tool connects to Azure Monitor, retrieves CPU metrics for specified virtual machines, and generates an Excel report containing:
- Virtual Machine Name
- Subscription
- Resource Group
- Maximum CPU Utilization
- Number of occurrences of peak utilization
 
The report can be used for:
- Capacity planning
- Performance investigations
- VM rightsizing exercises
- Resource optimization reviews
- Operational reporting
 
---
 
## Features
✅ Multi-subscription support
✅ Azure Monitor integration
✅ Automated Excel report generation
✅ Peak CPU utilization detection
✅ Error handling and reporting
✅ Bulk VM processing through Excel input
 
---
 
## Prerequisites
PowerShell Modules:
```powershell
Az.Compute
Az.Monitor
ImportExcel

---

**## Usage**
.\Get-VMCPUReport.ps1


