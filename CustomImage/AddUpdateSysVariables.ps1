Param(
    [string]$UserName, 
    [string]$Password,
    [string] $UserDomain
)
 
[Environment]::SetEnvironmentVariable("PATH", "C:\Program Files\CLI;C:\Program Files\NodeJS", [System.EnvironmentVariableTarget]::Machine)
$domainuser = "$UserDomain\$UserName"
write-output("Checking user account ...")
$hostname = $([Environment]::MachineName).tolower()
$domainname = $([Environment]::UserDomainName).tolower()
$thisuser = $([Environment]::UserName).tolower()

write-output("Current user is ""$domainname\$thisuser"" on ""$hostname"".")
write-output("Want to execute script when logged in as ""$UserName"".")
   
$securePwd = ConvertTo-SecureString $Password -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential $domainuser, $securePwd

$command = { cmdkey /generic:O365 /user:spo_farm2@viacom.com /pass:Pass1
    cmdkey /generic:2013farm /user:mtvn\sp_prd13_farm /pass:Pass2
    cmdkey /generic:O365Viacom /user:spo_farm2@viacom.com /pass:Pass3
}

try {
    Start-Process powershell -Credential $credential -ArgumentList "-noexit -command & {$command}" -Wait
    write-output("New process started.")
}
catch {
    write-output("New process failed to start.")
}
write-output("Run-once script on local VM finished.")
