# Install PowerShell modules
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name PnP.PowerShell -Scope AllUsers -Repository PSGallery
Install-Module -Name CredentialManager -Scope AllUsers -Repository PSGallery
Set-PSRepository -Name PSGallery -InstallationPolicy Untrusted

