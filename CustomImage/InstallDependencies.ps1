#install Node JS
# Define the Node.js version to install
$nodeVersion = "14.18.1"

# Define the installation path for Node.js
$installPath = "C:\Program Files\nodejs"

# Check if an existing version of Node.js is installed and determine the version number
$existingVersion = $null
if (Test-Path "$installPath\node.exe") {
    $existingVersion = node -v
}

# If an older version of Node.js is installed, uninstall it and remove the environment variables
if ($existingVersion -ne $null -and $existingVersion -lt "v$nodeVersion") {
     Start-Process msiexec.exe -Wait -ArgumentList "/x `"$installPath\node-$existingVersion-x64.msi`" /qn"
    [Environment]::SetEnvironmentVariable("NODEJS_HOME", $null, "Machine")
    [Environment]::SetEnvironmentVariable("NODEJS_VERSION", $null, "Machine")
    $oldPath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    $newPath = $oldPath.Replace("$installPath;", "")
    [Environment]::SetEnvironmentVariable("PATH", "$newPath", "Machine")
}

# If Node.js is not installed or an older version was uninstalled, download and install the latest version
if ($existingVersion -eq $null -or $existingVersion -lt "v$nodeVersion") {
    Invoke-WebRequest -Uri "https://nodejs.org/dist/v$nodeVersion/node-v$nodeVersion-x64.msi" -OutFile "$env:TEMP\nodejs.msi"
    Start-Process msiexec.exe -Wait -ArgumentList "/i `"$env:TEMP\nodejs.msi`" /qn INSTALLLOCATION=`"$installPath`""
    Remove-Item "$env:TEMP\nodejs.msi"
}

# Set up environment variables for Node.js
[Environment]::SetEnvironmentVariable("NODEJS_HOME", "$installPath", "Machine")
[Environment]::SetEnvironmentVariable("NODEJS_VERSION", "$nodeVersion", "Machine")
[Environment]::SetEnvironmentVariable("PATH", "$installPath;$env:PATH", "Machine")

# Verify Node.js installation
$nodeinstalledversion=node -v

Write-Host "Installed Node version is $nodeinstalledversion"


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
