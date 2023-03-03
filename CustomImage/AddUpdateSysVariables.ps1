Param(
    [string]$UserName, 
    [string]$Password,
    [string] $UserDomain
)
{
    
    $domainuser="$UserDomain\$Myuser"
    write-output("Checking user account ...")
    $hostname = $([Environment]::MachineName).tolower()
    $domainname = $([Environment]::UserDomainName).tolower()
    $thisuser = $([Environment]::UserName).tolower()

    write-output("- Current user is ""$domainname\$thisuser"" on ""$hostname"".")
    write-output("- Want to be user ""$UserName"".")
   
    $securePwd = ConvertTo-SecureString $Password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential $domainuser, $securePwd

            $command = {cmdkey /generic:O365 /user:spo_farm2@viacom.com /pass:Pass1
cmdkey /generic:2013farm /user:mtvn\sp_prd13_farm /pass:Pass2
cmdkey /generic:O365Viacom /user:spo_farm2@viacom.com /pass:Pass3

[Environment]::SetEnvironmentVariable("PATH", "value2", [System.EnvironmentVariableTarget]::User)
[Environment]::SetEnvironmentVariable("ENV_1", "value1", [System.EnvironmentVariableTarget]::User)
}

            try {
                Start-Process powershell -Credential $credential -ArgumentList "-noexit -command & {$command}"
                write-output("    - New process started.")
            } catch {
                write-output("    - New process failed to start.")
            }
            write-output("Run-once script on local VM finished.")

}
