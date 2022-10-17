. $PSScriptRoot\FetchRainfallReadingByAddress.ps1
. $PSScriptRoot\FetchDataFromRainfallAPI.ps1


$http = [System.Net.HttpListener]::new() 
$http.Prefixes.Add("http://+:8080/")
$http.Start()

if ($http.IsListening) {
    write-host "Rainfall Service started" -f 'black' -b 'gre'
    write-host "Direct Post API : $($http.Prefixes)direct_api" -f 'y'
    write-host "Config API : $($http.Prefixes)config_api" -f 'y'
}


while ($http.IsListening) {
    $context = $http.GetContext()
    if ($context.Request.HttpMethod -eq 'POST' -and $context.Request.RawUrl -eq '/direct_api') {
        $FormContent = [System.IO.StreamReader]::new($context.Request.InputStream).ReadToEnd()
        $inputReq = $FormContent | ConvertFrom-Json

        try {
            Write-Host "Fetching data for address $($inputReq.search_term) from url $($inputReq.url)" -f 'green'
            $rainfallData = FetchDataFromRainfallAPI -weburl $inputReq.url 
            $output = FetchRainfallReadingByAddress -address $inputReq.search_term -rainfallInfo $rainfallData

            if ($output -eq "") {
                Write-Host "No data found for address $($inputReq.search_term) from url $($inputReq.url)" -f 'yellow'
                $output = "No details found for given location"
            }
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($output)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
            $context.Response.OutputStream.Close() 
        }
        catch {
            if ($_.Exception.Message -like 'Invalid URI') {
                $context.Response.StatusCode = 400
            }
            else {
                $context.Response.StatusCode = 500
            }
            $context.Response.OutputStream.Close() 
        }
    }
    elseif ($context.Request.HttpMethod -eq 'GET' -and $context.Request.RawUrl -eq '/config_api') {
        $configFilePath = "/var/config/dtest/app.properties"
        if (-not (Test-Path $configFilePath)) {   
            Write-Host "Config file not found. Please fix path of config file." -f 'red'
            $context.Response.StatusCode = 500
            $context.Response.OutputStream.Close() 
        }
        $appProps = convertfrom-stringdata (Get-content $configFilePath -raw)
        
        try {
            Write-Host "Fetching data for address $($appProps.search_term)  from url $($appProps.url)" -f 'green'
            $rainfallData = FetchDataFromRainfallAPI -weburl $appProps.url 
            $output = FetchRainfallReadingByAddress -address $appProps.search_term -rainfallInfo $rainfallData

            if ($output -eq "") {
                Write-Host "No data found for address $($appProps.search_term) from url $($appProps.url)" -f 'yellow'
                $output = "No details found for given location"
            }
    
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($output)
            $context.Response.ContentLength64 = $buffer.Length
            $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
            $context.Response.OutputStream.Close() 
        }
        catch {
            Write-Host $_.Exception.Message 
            if ($_.Exception.Message -like 'Invalid URI') {
                $context.Response.StatusCode = 400
            }
            else {
                $context.Response.StatusCode = 500
            }
            $context.Response.OutputStream.Close() 
        }
    }
    else {
        Write-Host "Not a valid route. URL : $($context.Request.RawUrl) . Method : $($context.Request.HttpMethod)" -f 'red'
        $buffer = [System.Text.Encoding]::UTF8.GetBytes("Invalid Route")
        $context.Response.StatusCode = 404
        $context.Response.ContentLength64 = $buffer.Length
        $context.Response.OutputStream.Write($buffer, 0, $buffer.Length)
        $context.Response.OutputStream.Close() 
    }

} 
