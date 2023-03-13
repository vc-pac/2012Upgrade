Param(
    [string]$UserName, 
    [string]$Password,
    [string] $UserDomain
)
 
[Environment]::SetEnvironmentVariable("PATH", "C:\Program Files\Terraforms;C:\Program Files\NodeJS", [System.EnvironmentVariableTarget]::Machine)

$domainuser = "$UserDomain\$UserName"
write-output("Validating user account")
$hostname = $([Environment]::MachineName).tolower()
$domainname = $([Environment]::UserDomainName).tolower()
$thisuser = $([Environment]::UserName).tolower()

write-output("Current user is ""$domainname\$thisuser"" on ""$hostname"".")
write-output("Want to execute script when logged in as ""$UserName"".")
   
$securePwd = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $domainuser, $securePwd

$taskName = "Add credentials"
$datetimeStamp = Get-Date -Format "ddMMMyyyyHHmmss"
    $CredsFileName = "Creds_" + $datetimeStamp + ".ps1"
    $credsFilePath = Join-Path (Get-Location) -ChildPath $CredsFileName
    $newItem = New-Item -Path $credsFilePath -Force -ItemType File

    Add-Content -Path $credsFilePath "C:\Windows\system32\cmdkey.exe /generic:O365 /user:test@test.com /pass:Pass1"
    Add-Content -Path $credsFilePath "C:\Windows\system32\cmdkey.exe /generic:2013farm /user:abc\test1 /pass:Pass2"
    
    write-output("Creds File Path is ""$credsFilePath"".")


try {

write-output("Creating local user")
$localusername = 'AzDevOps'
$localpassword = (New-Guid).ToString()
write-output("Local user password is ""$localpassword"".")
$securelocalPassword = ConvertTo-SecureString $localpassword -AsPlainText -Force

$localuser = New-LocalUser -Name $localusername -Password $securelocalPassword
Write-Output $localuser.name
Write-Output $localuser
$localcredentials = New-Object System.Management.Automation.PSCredential($localuser.name, $securelocalPassword)
write-output("Created local user is ""$localuser"".")

Add-LocalGroupMember -Group "Administrators" -Member $localusername

$user = Get-LocalGroupMember -Group "Administrators" -Member $localusername -ErrorAction Ignore
$user

$sta = New-ScheduledTaskAction -Execute "c:\Windows\System32\WindowsPowerShell\v1.0\PowerShell.exe" -Argument $credsFilePath
$time = New-ScheduledTaskTrigger -At (Get-Date) -Once 
Register-ScheduledTask -TaskName "cmdKeySvcAccnt" -User $localuser.name -Password $localpassword -RunLevel Highest -Trigger $time -Action $sta -Force
     
}
catch {
    write-output("New process failed to start.")
    Write-Output $Error
}
write-output("Run-once script on local VM finished.")
