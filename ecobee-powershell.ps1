$APIKey = ""
$AuthCode = ""
$RefreshToken = ""
$ThermometerRoom = ""

# Get access token
if ((Get-Date) -gt $AuthTokenDate.addMinutes(-60)) {
    $AuthToken = Invoke-RestMethod -Uri "https://api.ecobee.com/token?grant_type=refresh_token&refresh_token=$($RefreshToken)&client_id=$($APIKey)&ecobee_type=jwt" -Method Post
    $AuthTokenDate = Get-Date
}

$AccessParams = @{
    Uri = 'https://api.ecobee.com/1/thermostat?format=json&body={"selection":{"selectionType":"registered","selectionMatch":"","includeRuntime":true,"includeSensors":true}}'
    Authentication = "Bearer"
    Token = $AuthToken.access_token | ConvertTo-SecureString -AsPlainText -Force
}
$ThermostatInfo = Invoke-RestMethod @AccessParams
$CurrentTemperature = (($ThermostatInfo.thermostatList.remoteSensors | Where-Object { $_.name -eq $ThermometerRoom }).capability[0].value) / 10
$CurrentHumidity = ($ThermostatInfo.thermostatList.remoteSensors | Where-Object { $_.name -eq "Thermostat" }).capability[1].value

Write-Host "Current Home Temperature: $($CurrentTemperature)° F"
Write-Host "Current Home Humidity: $($CurrentHumidity)%"
