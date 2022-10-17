Function FetchRainfallReadingByAddress {
    param (
        [string]$address , $rainfallInfo  
    )

    $output = ""
    $stationList = $rainfallInfo.metadata.stations
    $unit = $rainfallInfo.metadata.reading_unit
    $readingList = $rainfallInfo.items

    $stationId = ""
    foreach ($station in $stationList) {
        if ($station.name -eq $address.Trim()) {
            $stationId = $station.id
            $output = $output + $station.name 
            break
        }
    }

    if ($stationId -ne "") {
        $lastTimeReading = 0
        $lastReadingTS = ""
        foreach ($readings in $readingList) {
            $readingTS = [datetime]$readings.timestamp
            $readingTS = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($readingTS,"UTC")
            $readingTime = $readingTS.AddHours(8).ToString("HH:mm")
            foreach ($reading in $readings.readings) {
                if ($reading.station_id -eq $stationId) {
                    $lastTimeReading = $reading.value
                    $lastReadingTS = $readingTime
                }
            }   
        }      
        
        if ($lastTimeReading -gt 0.0) {
            $output = $output + ", " + $lastReadingTS + ", " + $lastTimeReading + $unit + ", " + "Raining"
        }
        else {
            $output = $output + ", " + $lastReadingTS + ", " + $lastTimeReading + $unit + ", " + "Not Raining"
        }
    }

    return $output
}
