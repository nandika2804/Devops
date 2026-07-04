<#
Exports all NSG rules from an Azure subscription.
Guaranteed: no System.Object[], no List`1[String], no type leakage.
#>



param(
    [Parameter(Mandatory)]
    [string]$SubscriptionId,



    [string]$OutPath = ".\All-NSG-Rules.csv"
)



$ErrorActionPreference = "Stop"



function Log {
    param([string]$m)
    Write-Host "[INFO] $m" -ForegroundColor Cyan
}



# ---------- HARD NORMALIZER (THE FIX) ----------
function Flatten-ToString {
    param($Value)



    if ($null -eq $Value) { return @() }



    # Force enumeration no matter the underlying type
    $out = @()
    foreach ($v in @($Value)) {
        if ($null -ne $v) {
            $out += "$v"
        }
    }
    return $out
}



function Normalize-Address {
    param ($Prefixes, $Prefix, $Asgs)



    $vals = @()



    $vals += Flatten-ToString $Prefixes
    $vals += Flatten-ToString $Prefix



    if ($Asgs) {
        foreach ($asg in $Asgs) {
            if ($asg.Id) {
                $vals += "ASG:$($asg.Id.Split('/')[-1])"
            }
        }
    }



    if ($vals.Count -eq 0) { return "*" }
    return ($vals -join ", ")
}



function Normalize-Port {
    param ($PortRanges, $PortRange)



    $vals = @()
    $vals += Flatten-ToString $PortRanges
    $vals += Flatten-ToString $PortRange



    if ($vals.Count -eq 0) { return "*" }
    return ($vals -join ", ")
}



# ---------- AUTH ----------
if (-not (Get-AzContext -ErrorAction SilentlyContinue)) {
    Connect-AzAccount | Out-Null
}



Select-AzSubscription -SubscriptionId $SubscriptionId | Out-Null
Log "Using subscription: $SubscriptionId"



# ---------- MAIN ----------
$results = @()
$nsgs = Get-AzNetworkSecurityGroup
Log "NSGs found: $($nsgs.Count)"



foreach ($nsg in $nsgs) {
    foreach ($rule in $nsg.SecurityRules) {



        $results += [pscustomobject]@{
            SubscriptionId  = $SubscriptionId
            ResourceGroup   = $nsg.ResourceGroupName
            NSG             = $nsg.Name
            RuleName        = $rule.Name
            Priority        = $rule.Priority
            Direction       = $rule.Direction
            Access          = $rule.Access
            Protocol        = ($rule.Protocol -eq "*" ? "Any" : $rule.Protocol)



            Source = Normalize-Address `
                $rule.SourceAddressPrefixes `
                $rule.SourceAddressPrefix `
                $rule.SourceApplicationSecurityGroups



            SourcePort = Normalize-Port `
                $rule.SourcePortRanges `
                $rule.SourcePortRange



            Destination = Normalize-Address `
                $rule.DestinationAddressPrefixes `
                $rule.DestinationAddressPrefix `
                $rule.DestinationApplicationSecurityGroups



            DestinationPort = Normalize-Port `
                $rule.DestinationPortRanges `
                $rule.DestinationPortRange
        }
    }
}



# ---------- EXPORT ----------
$results | Export-Csv -Path $OutPath -NoTypeInformation -Encoding UTF8
Log "Export completed: $OutPath"
 
