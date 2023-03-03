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

$command = { C:\Windows\system32\cmdkey.exe /generic:O365 /user:spo_farm2@viacom.com /pass:Pass1
    C:\Windows\system32\cmdkey.exe /generic:2013farm /user:mtvn\sp_prd13_farm /pass:Pass2
    C:\Windows\system32\cmdkey.exe /generic:O365Viacom /user:spo_farm2@viacom.com /pass:Pass3
}
try {
    $job = Start-Job -ScriptBlock {

    cmdkey.exe /generic:O365 /user:spo_farm2@viacom.com /pass:Pass1
    cmdkey.exe /generic:2013farm /user:mtvn\sp_prd13_farm /pass:Pass2
    cmdkey.exe /generic:O365Viacom /user:spo_farm2@viacom.com /pass:Pass3

} -Credential $credential

    Write-Output $job.ChildJobs[0].JobStateInfo.Reason.Message
    Write-Output $job.ChildJobs[0].Error
    write-output("New process started.")
}
catch {
    write-output("New process failed to start.")
}
write-output("Run-once script on local VM finished.")
