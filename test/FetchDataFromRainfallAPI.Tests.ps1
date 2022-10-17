Import-Module Pester

BeforeAll {
    . $PSScriptRoot/../app/FetchRainfallReadingByAddress.ps1
    . $PSScriptRoot/../app/FetchDataFromRainfallAPI.ps1
}

Describe "FetchDataFromRainfallAPI" {
    It "Valid Request" {
        Mock -CommandName Invoke-WebRequest -ParameterFilter { $Method -eq 'GET' } -MockWith { Import-Clixml test/testResponse.xml }
        $response = Invoke-WebRequest -Method 'GET' -Uri 'https://api.data.gov.sg/v1/environment/rainfall'
        $rainfallData = $response.Content | ConvertFrom-Json

        $actual = FetchDataFromRainfallAPI -weburl 'https://api.data.gov.sg/v1/environment/rainfall'
        $actual.metadata.reading_unit  | Should -Be  $rainfallData.metadata.reading_unit
        $actual.metadata.stations.Length  | Should -Be  $rainfallData.metadata.stations.Length
        ($actual.metadata.stations | ConvertTo-Json) | Should -Be  ($rainfallData.metadata.stations | ConvertTo-Json)
        ($actual.items | ConvertTo-Json) | Should -Be  ($rainfallData.items | ConvertTo-Json)
    }
    
    It "Invalid uri" {
        {FetchDataFromRainfallAPI -weburl 'https://api1.data.gov.sg/v1/environment/rainfall'} | Should -Throw 'Invalid URI'
    }

    It "Error while calling valid uri" {
        Mock Invoke-WebRequest {
            $status = [System.Net.WebExceptionStatus]::ConnectionClosed
            $response = New-MockObject -type 'System.Net.HttpWebResponse'
            $exception = New-Object System.Net.WebException "Fout" , $null, $status, $response    
            Throw $exception
        }
        {FetchDataFromRainfallAPI -weburl 'https://api.data.gov.sg/v1/environment/rainfall'} | Should -Throw 'Internal Server Error'
    }
}