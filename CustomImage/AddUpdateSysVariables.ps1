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

$datetimeStamp = Get-Date -Format "ddMMMyyyyHHmmss"
    $CredsFileName = "Creds_" + $datetimeStamp + ".ps1"
    $credsFilePath = Join-Path (Get-Location) -ChildPath $CredsFileName
    $newItem = New-Item -Path $credsFilePath -Force -ItemType File

    Add-Content -Path $credsFilePath "C:\Windows\system32\cmdkey.exe /generic:O365 /user:test@test.com /pass:Pass1"
    Add-Content -Path $credsFilePath "C:\Windows\system32\cmdkey.exe /generic:2013farm /user:abc\test1 /pass:Pass2"
    
    Write-Output $credsFilePath


try {
$runAsAdmin = New-ScheduledJobOption -RunElevated
   $job = Register-ScheduledJob -ScriptBlock {
     C:\Windows\system32\cmdkey.exe /generic:test /user:test@test.com /pass:Pass1
} -Name "Add credentials" -Credential $credential -RunNow -Verbose -ScheduledJobOption $runAsAdmin

$jobID = (Get-ScheduledJob -Name 'Add credentials').Id
Write-Output $jobID

}
catch {
    write-output("New process failed to start.")
}
write-output("Run-once script on local VM finished.")
