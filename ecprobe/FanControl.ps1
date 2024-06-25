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

[Int]$currentFS = -1;

foreach ($hardwareItem in $hwmon.Hardware){
    if($hardwareItem.HardwareType -eq [OpenHardwareMonitor.Hardware.HardwareType]::CPU){
        $hardwareItem.Update()
        foreach ($sensor in $hardwareItem.Sensors){
            if ($sensor.SensorType -eq "Temperature"){
                while ($true){
                    if ($sensor.Value -lt 35){
                        if ($currentFS -eq 0) {
                            while ($sensor.Value -lt 35) {
                                Start-Sleep -Milliseconds 3000
                                $hardwareItem.Update()
                                # $sensor.Value
                            }
                        }
                        else {
                            $currentFS = 0;
                            # Write-Host "Writing to EC - Fanspeed 0"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "0")
                        }
                    }
                    elseif ($sensor.Value -lt 40){
                        if ($currentFS -eq 30) {
                            while ($sensor.Value -lt 40) {
                                Start-Sleep -Milliseconds 2000
                                $hardwareItem.Update()
                                # $sensor.Value
                            }
                        }
                        else {
                            $currentFS = 30;
                            # Write-Host "Writing to EC - Fanspeed 30"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "30")
                        }
                    }
                    elseif ($sensor.Value -lt 50){
                        if ($currentFS -eq 50) {
                            while ($sensor.Value -lt 50) {
                                Start-Sleep -Milliseconds 1000
                                $hardwareItem.Update()
                                # $sensor.Value
                            }
                        }
                        else {
                            $currentFS = 50;
                            # Write-Host "Writing to EC - Fanspeed 50"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "50")
                        }
                    }
                    elseif ($sensor.Value -lt 75){
                        if ($currentFS -eq 60) {
                            while ($sensor.Value -lt 75) {
                                Start-Sleep -Milliseconds 500
                                $hardwareItem.Update()
                                # $sensor.Value
                            }
                        }
                        else {
                            $currentFS = 60;
                            # Write-Host "Writing to EC - Fanspeed 60"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "60")
                        }
                    }
                    elseif ($sensor.Value -lt 80){
                        if ($currentFS -eq 80) {
                            while ($sensor.Value -lt 80) {
                                Start-Sleep -Milliseconds 500
                                $hardwareItem.Update()
                                # $sensor.Value
                            }
                        }
                        else {
                            $currentFS = 80;
                            # Write-Host "Writing to EC - Fanspeed 80"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "80")
                        }
                    }
                    elseif ($sensor.Value -ge 80){
                        if ($currentFS -eq 100) {
                            while ($sensor.Value -gt 70) {
                                Start-Sleep -Milliseconds 500
                                $hardwareItem.Update()
                                # $sensor.Value
                            }
                        }
                        else {
                            $currentFS = 100;
                            # Write-Host "Writing to EC - Fanspeed 100"
                            Start-Process -WindowStyle Hidden -Wait -filePath $PSScriptRoot\"ec-probe.exe" -ArgumentList("write", "44", "100")
                        }
                    }
                }
            }
        }
    }
}
$hwmon.Close();
