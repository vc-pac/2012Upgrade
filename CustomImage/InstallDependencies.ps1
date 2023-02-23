# Install specific versions of PowerShell modules from the PowerShell Gallery
$modules = @(
    @{ Name = "Az"; Version = "2.0.0" },
    @{ Name = "Az.Accounts"; Version = "1.5.2" },
    @{ Name = "AzureAD"; Version = "2.0.2.130" },
    @{ Name = "CredentialManager"; Version = "2.0.0" },
    @{ Name = "ExchangeOnlineManagement"; Version = "2.0.5" },
    @{ Name = "Microsoft.Graph"; Version = "1.7.0" },
    @{ Name = "MicrosoftTeams"; Version = "4.4.1" },
    @{ Name = "SharePointPnPPowerShell2013"; Version = "3.26.2010.0" },
    @{ Name = "SharePointPnPPowerShellOnline"; Version = "3.25.2009.1" }
)

foreach ($module in $modules) {
    $moduleName = $module.Name
    $moduleVersion = $module.Version
    if (-not (Get-Module -Name $moduleName -ErrorAction SilentlyContinue)) {
        Write-Host "Installing module $moduleName version $moduleVersion ..."
        Install-Module -Name $moduleName -RequiredVersion $moduleVersion -Force
    } else {
        Write-Host "Module $moduleName version $moduleVersion is already installed."
    }
}