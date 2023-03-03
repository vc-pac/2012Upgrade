Param(
    [string]$UserName, 
    [string]$Password,
    [string] $UserDomain
)
{
    [Environment]::SetEnvironmentVariable("PATH", "value22", [System.EnvironmentVariableTarget]::Machine)
   [Environment]::SetEnvironmentVariable("ENV_1", "value11", [System.EnvironmentVariableTarget]::Machine)

    

}
