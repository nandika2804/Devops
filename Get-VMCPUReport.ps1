#Requires -Modules Az.Compute,Az.Monitor,ImportExcel

$InputFile  = "./InputVMs.xlsx"
$OutputFile = "./VM_CPU_Report.xlsx"

$InputVMs = Import-Excel $InputFile | Where-Object {
    $_.VMName -and $_.Subscription
}

$Results = @()

foreach ($Item in $InputVMs)
{
    $VMName = $Item.VMName.Trim()
    $SubscriptionName = $Item.Subscription.Trim()

    Write-Host "Processing $VMName in $SubscriptionName" -ForegroundColor Cyan

    try
    {
        Set-AzContext -SubscriptionName $SubscriptionName -ErrorAction Stop | Out-Null

        $VM = Get-AzVM -Name $VMName -ErrorAction Stop

        $Metric = Get-AzMetric `
            -ResourceId $VM.Id `
            -MetricName "Percentage CPU" `
            -AggregationType Maximum `
            -StartTime (Get-Date).AddDays(-30) `
            -EndTime (Get-Date)

        $CpuValues = $Metric.Data |
            Where-Object { $_.Maximum -ne $null } |
            Select-Object -ExpandProperty Maximum

        if ($CpuValues.Count -gt 0)
        {
            $MaxCPU = ($CpuValues | Measure-Object -Maximum).Maximum

            $HitCount = ($CpuValues | Where-Object {
                $_ -eq $MaxCPU
            }).Count
        }
        else
        {
            $MaxCPU = "No Metrics"
            $HitCount = 0
        }

        $Results += [PSCustomObject]@{
            VMName                 = $VM.Name
            Subscription           = $SubscriptionName
            ResourceGroup          = $VM.ResourceGroupName
            MaxCPUUtilization      = $MaxCPU
            MaxUtilizationHitCount = $HitCount
        }
    }
    catch
    {
        Write-Warning "$VMName : $($_.Exception.Message)"

        $Results += [PSCustomObject]@{
            VMName                 = $VMName
            Subscription           = $SubscriptionName
            ResourceGroup          = ""
            MaxCPUUtilization      = "ERROR"
            MaxUtilizationHitCount = ""
        }
    }
}

$Results |
    Export-Excel `
        -Path $OutputFile `
        -WorksheetName "CPU_Report" `
        -AutoSize `
        -BoldTopRow `
        -FreezeTopRow

Write-Host ""
Write-Host "Report generated successfully: $OutputFile" -ForegroundColor Green
