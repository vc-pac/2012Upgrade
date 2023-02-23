$chromeUrl = "http://dl.google.com/chrome/install/375.126/chrome_installer.exe"
$chromeInstaller = "$env:TEMP\ChromeInstaller.exe"
Invoke-WebRequest -Uri $chromeUrl -OutFile $chromeInstaller

# Check if the download was successful
if (-not (Test-Path $chromeInstaller)) {
    Write-Error "Failed to download Google Chrome installer"
    exit 1
}

# Install Chrome silently
$installArgs = "/silent /install"
$process = Start-Process -FilePath $chromeInstaller -ArgumentList $installArgs -Wait

if ($process.ExitCode -eq 0) {
    Write-Host "Google Chrome has been successfully installed"
} else {
    Write-Error "Failed to install Google Chrome with exit code $($process.ExitCode)"
    exit 1
}
