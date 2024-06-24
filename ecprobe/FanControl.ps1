<#
.SYNOPSIS
    Automates ecprobe calls based on custom conditions
.NOTES
    SPDX-License-Identifier: LGPL
    Angelo Kim Hui Lim <angelokimhui@gmail.com>
#>

# Fix CPU Util bug after bootup
Start-Sleep -Seconds 1

Add-Type -Path $PSScriptRoot"\Plugins\OpenHardwareMonitorLib.dll"
$hwmon = New-Object -TypeName OpenHardwareMonitor.Hardware.Computer
$hwmon.CPUEnabled= 1;
$hwmon.Open();

foreach ($hardwareItem in $hwmon.Hardware)
{
 if($hardwareItem.HardwareType -eq [OpenHardwareMonitor.Hardware.HardwareType]::CPU){
    while ($true) 
    {
        $hardwareItem.Update()
        foreach ($sensor in $hardwareItem.Sensors)
        {
         if ($sensor.SensorType -eq "Temperature")
         {
            if ($sensor.Value -lt 30)
            {
             # Write-Host "Writing to EC - Fanspeed 0"
             Start-Process -WindowStyle Hidden -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "0")
             while ($sensor.Value -lt 30) {
              $hardwareItem.Update()
              # $sensor.Value
              Start-Sleep -Milliseconds 500
             }
            }
            elseif ($sensor.Value -lt 40)
            {
             # Write-Host "Writing to EC - Fanspeed 30"
             Start-Process -WindowStyle Hidden -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "30")
             while ($sensor.Value -gt 30 -and $sensor.Value -lt 45) {
              $hardwareItem.Update()
              # $sensor.Value
              Start-Sleep -Milliseconds 500
             }
            }
            elseif ($sensor.Value -lt 50)
            {
             # Write-Host "Writing to EC - Fanspeed 50"
             Start-Process -WindowStyle Hidden -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "50")
             while ($sensor.Value -gt 45 -and $sensor.Value -lt 65) {
              $hardwareItem.Update()
              # $sensor.Value
              Start-Sleep -Milliseconds 500
             }
            }
            elseif ($sensor.Value -lt 75)
            {
             # Write-Host "Writing to EC - Fanspeed 60"
             Start-Process -WindowStyle Hidden -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "60")
             while ($sensor.Value -gt 50 -and $sensor.Value -lt 75) {
              $hardwareItem.Update()
              # $sensor.Value
              Start-Sleep -Milliseconds 500
             }
            }
            elseif ($sensor.Value -lt 80)
            {
             # Write-Host "Writing to EC - Fanspeed 80"
             Start-Process -WindowStyle Hidden -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "80")
             while ($sensor.Value -gt 65 -and $sensor.Value -lt 80) {
              $hardwareItem.Update()
              # $sensor.Value
              Start-Sleep -Milliseconds 500
             }
            }
            elseif ($sensor.Value -gt 80)
            {
             # Write-Host "Critical - Max Fanspeed"
             Start-Process -WindowStyle Hidden -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "100")
             while ($sensor.Value -gt 70) {
              $hardwareItem.Update()
              # $sensor.Value
              Start-Sleep -Milliseconds 500
             }
            }
         }
        }
    }
 }
}
$hwmon.Close();