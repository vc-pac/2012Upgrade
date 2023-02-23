try{
    $nodeUrl = "https://nodejs.org/dist/v12.14.1/node-v12.14.1-x64.msi"
    $nodeInstaller = "$env:TEMP\node-v12.14.1-x64.msi"
    Invoke-WebRequest -Uri $nodeUrl -OutFile $nodeInstaller
    
    $installArgs = "/qn /i '$nodeInstaller'"
    
    # Install Node.js
    #$process = Start-Process -FilePath msiexec.exe -ArgumentList $installArgs -Wait -Passthru
    
    $process = Start-Process $nodeInstaller -Wait -ArgumentList "/quiet /passive" -PassThru
    
    # Check if Node.js was installed successfully
    if ($process.ExitCode -eq 0) {
        Write-Host "Node.js version 12.14.1 has been installed successfully"
    }
    else {
        Write-Host "Node.js installation failed"
    }
    }
    catch{
        Write-Host "An exception occurred: $_Exception.message"
    }