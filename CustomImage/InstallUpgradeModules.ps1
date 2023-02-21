$logFile = "C:\Temp\" + (Get-Date -Format 'yyyyMMdd') + '_softwareinstall.log'
function write-log {
    param ($message)
    Write-Output "$(Get-Date -Format 'yyyyMMdd') $message" | Out-File -Encoding utf8 $logFile -Append    
} 

try{
    #Install Terraform 0.12.21
    Invoke-WebRequest -Uri https://releases.hashicorp.com/terraform/0.12.21/terraform_0.12.21_windows_amd64.zip -OutFile .\terraform.zip
    Expand-Archive -Path .\terraform.zip -DestinationPath 'C:\Program Files\terraform'
    # Set Terraform environment variables
    [Environment]::SetEnvironmentVariable("PATH", "$env:PATH;C:\Program Files\terraform", [EnvironmentVariableTarget]::Machine)
    If(terraform -version){
        write-log "terraform has been installed successfully"
    }
    else {
        write-log "terrafrom not installed"
    }
}
catch{
    $ErrorMessage =$_.Exception.message
    write-log "Error while installing terraform $ErrorMessage"
}

# Install Git
Invoke-WebRequest -Uri https://github.com/git-for-windows/git/releases/download/v2.33.1.windows.1/Git-2.33.1-64-bit.exe -OutFile .\Git.exe
Start-Process .\Git.exe -Wait -ArgumentList '/SILENT /NORESTART'

# Install PowerShell modules
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PnP.PowerShell -Scope AllUsers -Repository PSGallery
Install-Module -Name CredentialManager -Scope AllUsers -Repository PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted