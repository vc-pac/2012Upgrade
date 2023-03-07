try{
	$nodeversion="12.14.1"
    $nodeUrl = "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x64.msi"
    $installPath = "C:\Program Files\nodejs"
    $nodeInstaller = "$env:TEMP\node-$nodeVersion-x64.msi"
    Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller

	$process = Start-Process $nodeInstaller -Wait -ArgumentList "/quiet /passive" -PassThru
	

    # Check if Node.js was installed successfully
    if ($process.ExitCode -eq 0) {
        Write-Host "Node.js version $nodeversion has been installed successfully"
        Write-Host "set environment variable"
        [Environment]::SetEnvironmentVariable("PATH", "$installPath;$env:PATH", "Machine")
    }
    else {
        Write-Host "Node.js installation failed"
    }
    }
    catch{
        Write-Host "An exception occurred: $_Exception.message"
    }

#Install Modules from PSGallery
function Install-PSGalleryModules {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [array]$Modules
    )

    Install-PackageProvider -Name 'NuGet' -Force

    foreach ($module in $Modules) {
        $moduleName = $module.Name
        $moduleVersion = $module.Version
        if (-not (Get-Module -Name $moduleName -ErrorAction SilentlyContinue)) {
            Write-Host "Installing module $moduleName version $moduleVersion ..."
            Install-Module -Name $moduleName -RequiredVersion $moduleVersion -Force
        } else {
            Write-Host "Module $moduleName version $moduleVersion is already installed."
        }
    }
}

$modules = @(
    @{ Name = "Az"; Version = "2.0.0" },
    @{ Name = "AzureAD"; Version = "2.0.2.130" },
    @{ Name = "CredentialManager"; Version = "2.0.0" },
    @{ Name = "ExchangeOnlineManagement"; Version = "2.0.5" },
    @{ Name = "Microsoft.Graph"; Version = "1.7.0" },
    @{ Name = "MicrosoftTeams"; Version = "4.4.1" },
    @{ Name = "SharePointPnPPowerShellOnline"; Version = "3.25.2009.1" }
)

Install-PSGalleryModules -Modules $modules


#Set Credentials in windows credential manager
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
