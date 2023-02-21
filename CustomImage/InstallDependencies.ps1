#Install Terraform 0.12.21
Invoke-WebRequest -Uri https://releases.hashicorp.com/terraform/0.12.21/terraform_0.12.21_windows_amd64.zip -OutFile .\terraform.zip
Expand-Archive -Path .\terraform.zip -DestinationPath 'C:\Program Files\terraform'

# Set Terraform environment variables
[Environment]::SetEnvironmentVariable("PATH", "$env:PATH;C:\Program Files\terraform", [EnvironmentVariableTarget]::Machine)


# Install Git
Invoke-WebRequest -Uri https://github.com/git-for-windows/git/releases/download/v2.33.1.windows.1/Git-2.33.1-64-bit.exe -OutFile .\Git.exe
Start-Process .\Git.exe -Wait -ArgumentList '/SILENT /NORESTART'

# Install PowerShell modules
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PnP.PowerShell -Scope AllUsers -Repository PSGallery
Install-Module -Name CredentialManager -Scope AllUsers -Repository PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted
