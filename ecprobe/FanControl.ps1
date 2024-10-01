<#
.SYNOPSIS
    Automates ecprobe calls based on custom conditions
.NOTES
    SPDX-License-Identifier: LGPL
    Angelo Kim Hui Lim <angelokimhui@gmail.com>
#>

# Fix CPU Util bug after bootup
Start-Sleep -Seconds 1

Add-Type -Path "$PSScriptRoot\Plugins\OpenHardwareMonitorLib.dll"
$hwmon = New-Object -TypeName OpenHardwareMonitor.Hardware.Computer
$hwmon.CPUEnabled = $true
$hwmon.Open()

# Initialize fanspeed state
[Int]$currentFS = -1

# Helper function to set fan speed
function Set-FanSpeed {
    param (
        [int]$speed
    )
    if ($currentFS -ne $speed) {
        $currentFS = $speed
        Start-Process -WindowStyle Hidden -Wait -FilePath "$PSScriptRoot\ec-probe.exe" -ArgumentList "write", "44", "$speed"
    }
}

# Monitor CPU temperature and adjust fan speed accordingly
foreach ($hardwareItem in $hwmon.Hardware) {
    if ($hardwareItem.HardwareType -eq [OpenHardwareMonitor.Hardware.HardwareType]::CPU) {
        $hardwareItem.Update()

        foreach ($sensor in $hardwareItem.Sensors) {
            if ($sensor.SensorType -eq "Temperature") {
                while ($true) {
                    $hardwareItem.Update()
                    $temp = $sensor.Value

                    switch ($temp) {
                        { $_ -le 35 } { Set-FanSpeed 0; Start-Sleep -Seconds 3 }
                        { $_ -le 50 } { Set-FanSpeed 30; Start-Sleep -Seconds 2 }
                        { $_ -le 60 } { Set-FanSpeed 50; Start-Sleep -Seconds 5 }
                        { $_ -le 65 } { Set-FanSpeed 60; Start-Sleep -Seconds 5 }
                        { $_ -le 70 } { Set-FanSpeed 95; Start-Sleep -Seconds 5 }
                        default { Set-FanSpeed 100; Start-Sleep -Seconds 5 }
                    }
                }
            }
        }
    }
}

$hwmon.Close()
