Import-Module Pester


BeforeAll {
    . $PSScriptRoot/../app/FetchRainfallReadingByAddress.ps1
    . $PSScriptRoot/../app/FetchDataFromRainfallAPI.ps1
    Mock -CommandName Invoke-WebRequest -ParameterFilter { $Method -eq 'GET' } -MockWith { Import-Clixml test/testResponse.xml }
    $response = Invoke-WebRequest -Method 'GET' -Uri 'https://api.data.gov.sg/v1/environment/rainfall'
    $rainfallData = $response.Content | ConvertFrom-Json
    Write-Output $rainfallData
}
Describe  "FetchRainfallReadingByAddress" {
    It "Returns <expected> (<name>)" -TestCases @(
        @{ Address = "Ang Mo Kio Avenue 5"; Expected = "Ang Mo Kio Avenue 5, 11:55, 0.23mm, Raining" }
        @{ Address = "ang Mo Kio avenue 5"; Expected = "Ang Mo Kio Avenue 5, 11:55, 0.23mm, Raining" }
        @{ Address = "Bukit Panjang Road"; Expected = "Bukit Panjang Road, 11:55, 0mm, Not Raining" }
        @{ Address = "Alexandra Road"; Expected = "Alexandra Road, 11:55, 0.1mm, Raining" }
        @{ Address = "Test Address"; Expected = "" }
        @{ Address = ""; Expected = "" }
    ) {
        FetchRainfallReadingByAddress -address $address -rainfallInfo $rainfallData | Should -Be $expected
    }

    Describe  "FetchRainfallReadingByAddressWithEmptyRainfallInfo" {
        It "Returns <expected> (<name>)" -TestCases @(
            @{ Address = "Ang Mo Kio Avenue 5"; Expected = "" }
        ) {
            FetchRainfallReadingByAddress | Should -Be $expected
        }
    }

}