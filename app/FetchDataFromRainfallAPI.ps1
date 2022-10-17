Function FetchDataFromRainfallAPI {
    param (
        [string]$weburl 
    )

    if ($weburl -eq "" -or ($weburl -ne "https://api.data.gov.sg/v1/environment/rainfall" -and $weburl -NotLike "https://api.data.gov.sg/v1/environment/rainfall*")) {
        Write-Host "Invalid URI. Invalid url in request $weburl" -f 'red'
        throw "Invalid URI"
        return
   }
   try { 
        $response = Invoke-WebRequest -URI $weburl -Method Get -UseBasicParsing
        $jsonResponse = $response.Content | ConvertFrom-Json
        return $jsonResponse
    }
    catch [System.Net.WebException] { 
        $statusCodeInt = [int]$response.StatusCode
        Write-Host "Internal Server Error.Error code receive while calling $weburl . Status Code: $statusCodeInt" -f 'red'
        throw "Internal Server Error"
        return
    }
    
}
