# Set environment variables
$installPath = "C:\Program Files\cli"
[Environment]::SetEnvironmentVariable("PATH", "$installPath;$env:PATH", "Machine")
[Environment]::SetEnvironmentVariable("ENV_1", "value1", "Machine")

# Add credentials to Credential Manager
function Set-Credential {
    param (
        [Parameter(Mandatory=$true)]
        [hashtable[]]$Credentials
    )

    foreach ($credential in $Credentials) {
        $username = $credential.Username
        $password = $credential.Password
        $targetName = $credential.TargetName
    
        $securePassword = ConvertTo-SecureString $password -AsPlainText -Force
        $credentialObject = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
    
        cmdkey /generic:$targetName /user:$username /pass:$password
    }
}


 $credentials = @(
    @{Username='Username1'; Password='pass1'; TargetName='o365'},
    @{Username='Username2'; Password='pass2'; TargetName='viacom'},
    @{Username='Username3'; Password='pass3'; TargetName='o365viacom'}
    )
Write-Host "Adding credentials to credentialmanager..."
Set-Credential -Credentials $credentials