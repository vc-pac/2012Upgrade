
    $chromeUrl = "http://dl.google.com/chrome/install/375.126/chrome_installer.exe"
    $chromeInstaller = "$env:TEMP\ChromeInstaller.exe"
    Invoke-WebRequest -Uri $chromeUrl -OutFile $chromeInstaller
    
    # Install Chrome silently
    $installArgs = "/silent /install"
    $process = Start-Process -FilePath $chromeInstaller -ArgumentList $installArgs -Wait

    if ($process.ExitCode -eq 0) {
        Write-Host "Google Chrome has been successfully installed successfully"
    }

    else {
        Write-Host "Google Chrome not installed"
    }