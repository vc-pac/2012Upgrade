
try {
    # Install PnP.PowerShell module
    Write-Host "Installing PnP.PowerShell module..."
    Install-Module -Name PnP.PowerShell -RequiredVersion 1.11.0 -Force -ErrorAction Stop

    # Log successful installation
    Write-Host "PnP.PowerShell module installed successfully."

    # Install CredentialManager module
    Write-Host "Installing CredentialManager module..."
    Install-Module -Name CredentialManager -Force -ErrorAction Stop

    # Log successful installation
    Write-Host "CredentialManager module installed successfully."
}

catch {
    # Log error message
    Write-Host "Error occurred during module installation:`n$($_.Exception.Message)"

    # Throw exception to terminate script
    throw $_.Exception
}



