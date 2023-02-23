
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

try {
    # Install PnP.PowerShell module
    If(Find-Module PnP.PowerShell -RequiredVersion 1.11.0){
    Write-Host "Found pnp.powershell version 1.11.0 in PSGallery"
    Write-Host "Installing PnP.PowerShell module..."
    Install-Module -Name PnP.PowerShell -RequiredVersion 1.11.0 -Force -ErrorAction Stop

    # Log successful installation
    Write-Host "PnP.PowerShell module installed successfully."
    }
    elseif(Find-Module CredentialManager){
    Write-Host "Found CredentialManager in PSGallery"

    # Install CredentialManager module
    Write-Host "Installing CredentialManager module..."
    Install-Module -Name CredentialManager -Force -ErrorAction Stop

    # Log successful installation
    Write-Host "CredentialManager module installed successfully."
    }
    Else{
    Write-Host "No internet connectivity"
    }
}

catch {
    # Log error message
    Write-Host "Error occurred during module installation:`n$($_.Exception.Message)"

    # Throw exception to terminate script
    throw $_.Exception
}