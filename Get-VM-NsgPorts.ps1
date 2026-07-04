<#
.SYNOPSIS
  Export effective inbound/outbound port rules for a single Azure VM to Excel.

.OUTPUT
  Excel file (.xlsx) with columns:
    VM name, nsg, port, inbound, outbound, protocol, allow

.NOTES
  - Uses Effective NSG (merges NIC + Subnet NSGs) for accuracy.
  - Treats DESTINATION ports as “port” (server/listening side).
  - Source ports are ephemeral by design and intentionally ignored.
  - Requires: Az module. Optionally uses ImportExcel for .xlsx output
    (falls back to CSV if ImportExcel is not installed).
#>

param(
  [Parameter(Mandatory=$true)] [string] $SubscriptionId,
  [Parameter(Mandatory=$true)] [string] $ResourceGroup,
  [Parameter(Mandatory=$true)] [string] $VmName,
  [Parameter(Mandatory=$true)] [string] $Location,     # Same region as the VM, e.g. "Central India"
  [Parameter(Mandatory=$false)] [string] $OutPath = ".\${VmName}_ports.xlsx",

  # Optional: expand short numeric ranges like "1000-1005" into 1000,1001,... (cap to avoid explosion)
  [int] $MaxExpandRange = 50
)

# ---------- Helpers ----------
function Ensure-NetworkWatcher {
  param([string]$Region)
  $nw = Get-AzNetworkWatcher -Location $Region -ErrorAction SilentlyContinue
  if (-not $nw) {
    $rgName = "NetworkWatcherRG"
    try {
      $nw = New-AzNetworkWatcher -Name ("nw-" + $Region.Replace(" ","-").ToLower()) `
            -ResourceGroupName $rgName -Location $Region -ErrorAction Stop
    } catch {
      throw "Could not create/find Network Watcher in region '$Region'. $_"
    }
  }
  return $nw
}

function Expand-PortToken {
  param([string]$token, [int]$maxItems = 50)
  # token examples: "*", "22", "443", "8080-8090"
  if ([string]::IsNullOrWhiteSpace($token)) { return @("*") }
  if ($token -eq "*") { return @("*") }
  if ($token -match "^\d+$") { return @($token) }
  if ($token -match "^(?<s>\d+)-(?<e>\d+)$") {
    $s = [int]$Matches['s']; $e = [int]$Matches['e']
    $count = ($e - $s + 1)
    if ($count -gt 0 -and $count -le $maxItems) {
      return $s..$e | ForEach-Object { $_.ToString() }
    } else {
      # Too large to expand—keep the range as is
      return @("$s-$e")
    }
  }
  # Comma separated list or anything else—return as-is
  return @($token)
}

function Get-PortsFromRule {
  param($rule, [int]$maxExpand = 50)
  $dst = @()
  if ($rule.DestinationPortRanges) { $dst = $rule.DestinationPortRanges }
  elseif ($rule.DestinationPortRange) { $dst = @($rule.DestinationPortRange) }
  else { $dst = @("*") }

  $out = @()
  foreach ($t in $dst) {
    # Split on commas if API returned a single string with commas (defensive)
    $parts = ($t -is [string]) ? $t.Split(",") : @($t)
    foreach ($p in $parts) {
      $out += (Expand-PortToken -token ($p.Trim()) -maxItems $maxExpand)
    }
  }
  return $out
}

# ---------- Start ----------
$ErrorActionPreference = "Stop"

# Connect & set subscription
try {
  if (-not (Get-AzContext -ErrorAction SilentlyContinue)) { Connect-AzAccount | Out-Null }
  Select-AzSubscription -SubscriptionId $SubscriptionId | Out-Null
} catch {
  throw "Azure login/subscription selection failed. $_"
}

# Ensure Network Watcher in VM region (required for Effective NSG cmdlet)
Ensure-NetworkWatcher -Region $Location | Out-Null

# Find VM & NICs
$vm = Get-AzVM -ResourceGroupName $ResourceGroup -Name $VmName -Status
if (-not $vm) { throw "VM '$VmName' not found in RG '$ResourceGroup'." }
$nicIds = $vm.NetworkProfile.NetworkInterfaces.id

$rows = New-Object System.Collections.Generic.List[object]

foreach ($nicId in $nicIds) {
  $nicName = ($nicId.Split('/') | Select-Object -Last 1)
  $eff = Get-AzEffectiveNetworkSecurityGroup -NetworkInterfaceName $nicName -ResourceGroupName $ResourceGroup

  foreach ($ensg in $eff.EffectiveNetworkSecurityGroup) {
    $nsgName = $ensg.NetworkSecurityGroup.Id.Split('/')[-1]

    foreach ($rule in $ensg.EffectiveSecurityRules) {
      $ports = Get-PortsFromRule -rule $rule -maxExpand $MaxExpandRange
      $proto = if ([string]::IsNullOrEmpty($rule.Protocol) -or $rule.Protocol -eq "*") { "Any" } else { $rule.Protocol }
      $isInbound  = ($rule.Direction -eq "Inbound")
      $isOutbound = ($rule.Direction -eq "Outbound")
      $allowValue = $rule.Access  # "Allow" or "Deny"

      foreach ($port in $ports) {
        $rows.Add([pscustomobject]@{
          "VM name"   = $VmName
          "nsg"       = $nsgName
          "port"      = $port
          "inbound"   = $(if ($isInbound) { "Yes" } else { "No" })
          "outbound"  = $(if ($isOutbound) { "Yes" } else { "No" })
          "protocol"  = $proto
          "allow"     = $allowValue
        })
      }
    }
  }
}

# De-duplicate identical rows
$rows = $rows | Select-Object "VM name","nsg","port","inbound","outbound","protocol","allow" -Unique |
        Sort-Object "VM name","nsg","inbound","outbound","protocol","port"

# Export to Excel if ImportExcel module is present; else CSV
$ext = [System.IO.Path]::GetExtension($OutPath)
$dir = Split-Path -Parent $OutPath
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }

$importExcel = Get-Module -ListAvailable -Name ImportExcel
if ($ext -ieq ".xlsx" -and $importExcel) {
  $rows | Export-Excel -Path $OutPath -WorksheetName "ports" -AutoSize -AutoFilter -FreezeTopRow -BoldTopRow
  Write-Host "Excel created: $OutPath"
} else {
  # Fallback to CSV
  $csvPath = ($ext -ieq ".xlsx") ? [System.IO.Path]::ChangeExtension($OutPath,".csv") : $OutPath
  $rows | Export-Csv -Path $csvPath -NoTypeInformation -Encoding UTF8
  Write-Host "CSV created (open in Excel): $csvPath"
}
