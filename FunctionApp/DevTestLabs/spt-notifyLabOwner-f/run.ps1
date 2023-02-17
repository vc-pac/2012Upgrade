using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with the body of the request.
Write-Host $Request.Body

if ($null -ne $Request.Body.owner) {
    $inputPayload = $env:MessageConfig
    $labOwner = $Request.Body.owner
    $vmName = $Request.Body.vmName
    $delayUrl60 = $Request.Body.delayUrl60
    $delayUrl120 = $Request.Body.delayUrl120
    $inputPayload = $inputPayload.replace("{0}", $labOwner).replace("{1}", $vmName).replace("{2}", $delayUrl60).replace("{3}", $delayUrl120)
	     
    Write-Host "Sending My Assistant Notification" $inputPayload

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Content-Type", "application/text")

    $response = Invoke-RestMethod $env:MyAssistantNotificationAzFunction -Method "POST" -Headers $headers -Body $inputPayload
    $response = $response | ConvertTo-Json
    Write-Host $response
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = "HTTP triggered function executed successfully"
    })
