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
$localpassword = (New-Guid).ToString()
write-output("Local user password is ""$localpassword"".")
$securelocalPassword = ConvertTo-SecureString $localpassword -AsPlainText -Force

$localuser = New-LocalUser -Name "AzDevOps" -Password $securelocalPassword
Write-Output $localuser.name
Write-Output $localuser
$localcredentials = New-Object System.Management.Automation.PSCredential($localuser.name, $securelocalPassword)

write-output("Created local user is ""$localuser"".")

write-output("Registering scheduled job..")
   $job = Register-ScheduledJob -ScriptBlock {
     C:\Windows\system32\cmdkey.exe /generic:test12 /user:test@test.com /pass:Pass1
} -Name "Add credentials" -Verbose -RunNow -Credential $localcredentials

Write-Host " @ Let's look at running account of Add credentials PowerShell job"
$task = Get-ScheduledTask -TaskName "Add credentials"
$task
write-output($task.Principal.UserId) 

Write-Host " @ Let's start ""$taskName"" manually"
Start-Job -DefinitionName 'Add credentials' | Format-Table

Write-Host " @ Let's proof that Add credentials PowerShell job has been launched"; 
Write-Host;
Start-Sleep -Seconds 3
Receive-Job -Name $taskName
Write-Host;


}
catch {
    write-output("New process failed to start.")
    Write-Output $Error
}
write-output("Run-once script on local VM finished.")
