﻿<#
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

[Int]$currentFS = -1;

foreach ($hardwareItem in $hwmon.Hardware){
    if($hardwareItem.HardwareType -eq [OpenHardwareMonitor.Hardware.HardwareType]::CPU){
        $hardwareItem.Update()
        foreach ($sensor in $hardwareItem.Sensors){
            if ($sensor.SensorType -eq "Temperature"){
                while ($true){
                    if ($sensor.Value -lt 35){
                        if ($currentFS -ne 0) {
                            $currentFS = 0;
                            # Write-Host "Writing to EC - Fanspeed 0"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "0")
                        }
                        else {
                            while ($sensor.Value -lt 35) {
                                $hardwareItem.Update()
                                # $sensor.Value
                                Start-Sleep -Milliseconds 3000
                            }
                        }
                    }
                    elseif ($sensor.Value -lt 40){
                        if ($currentFS -ne 30) {
                            $currentFS = 30;
                            # Write-Host "Writing to EC - Fanspeed 30"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "30")
                        }
                        else {
                            while ($sensor.Value -gt 30 -and $sensor.Value -lt 45) {
                                $hardwareItem.Update()
                                # $sensor.Value
                                Start-Sleep -Milliseconds 2000
                            }
                        }
                    }
                    elseif ($sensor.Value -lt 50){
                        if ($currentFS -ne 50) {
                            $currentFS = 50;
                            # Write-Host "Writing to EC - Fanspeed 50"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "50")
                        }
                        else {
                            while ($sensor.Value -gt 40 -and $sensor.Value -lt 65) {
                                $hardwareItem.Update()
                                # $sensor.Value
                                Start-Sleep -Milliseconds 1000
                            }
                        }
                    }
                    elseif ($sensor.Value -lt 75){
                        if ($currentFS -ne 60) {
                            $currentFS = 60;
                            # Write-Host "Writing to EC - Fanspeed 60"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "60")
                        }
                        else {
                            while ($sensor.Value -gt 50 -and $sensor.Value -lt 75) {
                                $hardwareItem.Update()
                                # $sensor.Value
                                Start-Sleep -Milliseconds 500
                            }
                        }
                    }
                    elseif ($sensor.Value -lt 80){
                        if ($currentFS -ne 80) {
                            $currentFS = 80;
                            # Write-Host "Writing to EC - Fanspeed 80"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "80")
                        }
                        else {
                            while ($sensor.Value -gt 65 -and $sensor.Value -lt 80) {
                                $hardwareItem.Update()
                                # $sensor.Value
                                Start-Sleep -Milliseconds 500
                            }
                        }
                    }
                    elseif ($sensor.Value -gt 80){
                        if ($currentFS -ne 100) {
                            $currentFS = 100;
                            # Write-Host "Writing to EC - Fanspeed 100"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "100")
                        }
                        else {
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
}
$hwmon.Close();
