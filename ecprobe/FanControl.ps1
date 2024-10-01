<#
.SYNOPSIS
    Automates ecprobe calls based on custom conditions.
.NOTES
    SPDX-License-Identifier: LGPL
    Angelo Kim Hui Lim <angelokimhui@gmail.com>
#>

# Fix CPU Util bug after bootup
Start-Sleep -Seconds 1

# Load the hardware monitor library
Add-Type -Path "$PSScriptRoot\Plugins\OpenHardwareMonitorLib.dll"
$hwmon = New-Object -TypeName OpenHardwareMonitor.Hardware.Computer
$hwmon.CPUEnabled = $true
$hwmon.Open()

[Int]$currentFS = -1

# Function to update fan speed if necessary
function Set-FanSpeed {
    param (
        [int]$newSpeed
    )
    if ($currentFS -ne $newSpeed) {
        $currentFS = $newSpeed
        Start-Process -WindowStyle Hidden -Wait -FilePath "$PSScriptRoot\ec-probe.exe" -ArgumentList("write", "44", "$newSpeed")
    }
}

# Function to manage temperature monitoring and sleep duration
function Monitor-Temperature {
    param (
        [int]$targetMin,
        [int]$targetMax,
        [int]$fanSpeed,
        [int]$sleepDuration
    )

    Set-FanSpeed $fanSpeed

    while ($true) {
        $hardwareItem.Update()
        $sensorValue = $sensor.Value

        if ($sensorValue -lt $targetMax -and $sensorValue -gt $targetMin) {
            Start-Sleep -Seconds $sleepDuration
        } else {
            break
        }
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
                    $temperature = $sensor.Value

                    switch ($temperature) {
                        {$_ -le 35} {
                            Monitor-Temperature -targetMin 35 -targetMax 40 -fanSpeed 0 -sleepDuration 3
                        }
                        {$_ -le 50} {
                            Monitor-Temperature -targetMin 30 -targetMax 60 -fanSpeed 30 -sleepDuration 2
                        }
                        {$_ -le 60} {
                            Monitor-Temperature -targetMin 50 -targetMax 65 -fanSpeed 50 -sleepDuration 5
                        }
                        {$_ -le 65} {
                            Monitor-Temperature -targetMin 60 -targetMax 70 -fanSpeed 60 -sleepDuration 5
                        }
                        {$_ -le 70} {
                            Monitor-Temperature -targetMin 65 -targetMax 75 -fanSpeed 95 -sleepDuration 10
                        }
                        default {
                            Monitor-Temperature -targetMin 60 -targetMax [int]::MaxValue -fanSpeed 100 -sleepDuration 20
                        }
                    }
                }
            }
        }
    }
}

$hwmon.Close()
