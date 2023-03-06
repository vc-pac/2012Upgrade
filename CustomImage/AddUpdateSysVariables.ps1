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

$command = { C:\Windows\system32\cmdkey.exe /generic:O365 /user:test@test.com /pass:Pass1
    C:\Windows\system32\cmdkey.exe /generic:2013farm /user:abc\test1 /pass:Pass2
    C:\Windows\system32\cmdkey.exe /generic:O365Viacom /user:test2@gmail.com /pass:Pass3
}
try {
    $job = Start-Job -ScriptBlock {

    cmdkey.exe /generic:O365 /user:test@test.com /pass:Pass1
    cmdkey.exe /generic:2013farm /user:abc\test1 /pass:Pass2
    cmdkey.exe /generic:O365Viacom /user:test2@gmail.com /pass:Pass3

} -Credential $credential

    Write-Output $job.ChildJobs[0].JobStateInfo.Reason.Message
    Write-Output $job.ChildJobs[0].Error
    write-output("New process started.")
}
catch {
    write-output("New process failed to start.")
}
write-output("Run-once script on local VM finished.")
