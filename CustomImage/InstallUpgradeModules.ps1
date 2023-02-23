Write-Host "Installing module PowerShellGet..."
Install-Module -Name PowerShellGet -RequiredVersion 1.6.5 -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

Write-Host "Installing module CredentialManager ..."
Install-Module -Name CredentialManager
Write-Host "Installed module CredentialManager"
